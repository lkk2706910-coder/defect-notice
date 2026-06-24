using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

// Shared auth helper for ASP.NET WebForms (.NET Framework 4.x).
// Drop this into App_Code/ and any page can call:
//   AuthHelper.HandleLogin(...)
//   if (!AuthHelper.RequireAuth(...)) return;
//   if (!AuthHelper.RequireEditor(...)) return;
//
// Design choices (battle-tested -- preserve them):
//
// 1. Token table is a process-static Dictionary with sliding 8h expiry.
//    Cheap, no DB round-trip per request. Trade-off: tokens are lost on
//    IIS App Pool recycle, so all users get a needLogin and re-enter
//    credentials. Acceptable for internal-only sites.
//
// 2. RequireAuth NEVER returns HTTP 401. IIS Classic mode auto-appends a
//    WWW-Authenticate header on 401, which makes the browser pop the
//    native basic-auth box -- not what we want. We return HTTP 200 with
//    {"ok":false,"error":"needLogin"} and the client JS handles it
//    (showing our custom modal + preserving in-progress edits).
//
// 3. Users live in App_Data/users.json (one row per account: name, salt,
//    hash, role). NEVER store plaintext passwords. Generate the hash with
//    tools/user_hash.py.
//
// 4. Role gate: "editor" can read+mutate, "viewer" can only read. The
//    page's mutating ops call RequireEditor; read ops call RequireAuth.
//    Default role is "editor" when missing -- old accounts that pre-date
//    the role field keep their privileges.
public static class AuthHelper
{
    private class TokenInfo
    {
        public string Name;
        public string Role;
        public DateTime ExpiresAt;
    }

    private static readonly object _tokenLock = new object();
    private static readonly Dictionary<string, TokenInfo> _tokens =
        new Dictionary<string, TokenInfo>(StringComparer.Ordinal);
    private const int TokenLifetimeHours = 8;

    private static readonly object _usersLock = new object();

    public const string UsersFileRelative = "App_Data\\users.json";

    // ---- Handlers ----

    // Client POSTs {"username":"...", "password":"..."}.
    // Success returns {"ok":true, "name":"...", "role":"editor|viewer",
    //                  "token":"<base64-urlsafe>"}.
    // Failure returns {"ok":false, "error":"empty_fields|bad_credentials"}.
    // Always HTTP 200; the JS treats `ok:false` as a soft error.
    public static void HandleLogin(HttpContext ctx, string pageDir)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        ctx.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        string body;
        using (var reader = new StreamReader(ctx.Request.InputStream, Encoding.UTF8))
            body = reader.ReadToEnd();
        var ser = NewSerializer();
        Dictionary<string, object> req;
        try { req = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>(); }
        catch
        {
            ctx.Response.Write("{\"ok\":false,\"error\":\"invalid_json\"}");
            return;
        }
        string name = req.ContainsKey("username") ? (req["username"] ?? "").ToString().Trim() : "";
        string pwd  = req.ContainsKey("password") ? (req["password"] ?? "").ToString() : "";
        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(pwd))
        {
            ctx.Response.Write("{\"ok\":false,\"error\":\"empty_fields\"}");
            return;
        }

        var user = LoadUser(pageDir, name);
        bool ok = false;
        string role = "editor";
        if (user != null)
        {
            string salt = user.ContainsKey("salt") ? (user["salt"] ?? "").ToString() : "";
            string expectedHash = user.ContainsKey("hash") ? (user["hash"] ?? "").ToString() : "";
            string computed = Sha256B64(salt + pwd);
            ok = !string.IsNullOrEmpty(expectedHash) && ConstantTimeEquals(expectedHash, computed);
            if (user.ContainsKey("role"))
            {
                string r = (user["role"] ?? "").ToString().Trim().ToLowerInvariant();
                if (r == "viewer" || r == "editor") role = r;
            }
        }

        if (ok)
        {
            string token = NewToken();
            lock (_tokenLock)
            {
                // GC expired tokens on each successful login so the dict
                // can't grow forever.
                var now = DateTime.UtcNow;
                var dead = new List<string>();
                foreach (var kv in _tokens) if (kv.Value.ExpiresAt < now) dead.Add(kv.Key);
                foreach (var k in dead) _tokens.Remove(k);

                _tokens[token] = new TokenInfo
                {
                    Name = name,
                    Role = role,
                    ExpiresAt = now.AddHours(TokenLifetimeHours)
                };
            }
            ctx.Response.Write(
                "{\"ok\":true,\"name\":\"" + JsonEscape(name) +
                "\",\"role\":\"" + role +
                "\",\"token\":\"" + JsonEscape(token) + "\"}"
            );
        }
        else
        {
            ctx.Response.Write("{\"ok\":false,\"error\":\"bad_credentials\"}");
        }
    }

    // Gate for every protected op. Reads X-Auth-Token, looks it up,
    // applies sliding expiry. Returns false AND writes a 200 JSON failure
    // body when auth fails -- the caller should just `return;`. Stashes
    // the username + role in HttpContext.Items for downstream audit logs.
    public static bool RequireAuth(HttpContext ctx)
    {
        string token = ctx.Request.Headers["X-Auth-Token"];
        if (string.IsNullOrEmpty(token))
        {
            WriteNeedLogin(ctx);
            return false;
        }
        TokenInfo info;
        lock (_tokenLock)
        {
            if (!_tokens.TryGetValue(token, out info))
            {
                WriteNeedLogin(ctx);
                return false;
            }
            if (info.ExpiresAt < DateTime.UtcNow)
            {
                _tokens.Remove(token);
                WriteNeedLogin(ctx);
                return false;
            }
            // Sliding expiry: any successful request extends the session.
            info.ExpiresAt = DateTime.UtcNow.AddHours(TokenLifetimeHours);
        }
        ctx.Items["AuthUser"] = info.Name;
        ctx.Items["AuthRole"] = info.Role ?? "editor";
        return true;
    }

    // Gate for mutating ops. Viewer tokens can read (RequireAuth passes)
    // but cannot mutate.
    public static bool RequireEditor(HttpContext ctx)
    {
        if (!RequireAuth(ctx)) return false;
        string role = (ctx.Items["AuthRole"] ?? "editor").ToString();
        if (role != "editor")
        {
            ctx.Response.Write("{\"ok\":false,\"error\":\"readonly\"}");
            return false;
        }
        return true;
    }

    // Read the username that RequireAuth stashed in HttpContext.Items.
    // Returns "" before RequireAuth has run (or after it failed).
    public static string CurrentUser(HttpContext ctx)
    {
        return (ctx.Items["AuthUser"] ?? "").ToString();
    }

    public static string CurrentRole(HttpContext ctx)
    {
        return (ctx.Items["AuthRole"] ?? "").ToString();
    }

    // ---- Internals ----

    private static void WriteNeedLogin(HttpContext ctx)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        ctx.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        ctx.Response.Write("{\"ok\":false,\"error\":\"needLogin\"}");
    }

    private static string NewToken()
    {
        byte[] buf = new byte[24];
        using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(buf);
        return Convert.ToBase64String(buf).Replace("/", "_").Replace("+", "-").Replace("=", "");
    }

    private static IDictionary<string, object> LoadUser(string pageDir, string name)
    {
        string path = Path.Combine(pageDir, UsersFileRelative);
        if (!File.Exists(path)) return null;
        var ser = NewSerializer();
        Dictionary<string, object> doc;
        lock (_usersLock)
        {
            string current = File.ReadAllText(path, Encoding.UTF8);
            if (string.IsNullOrWhiteSpace(current)) return null;
            try { doc = ser.Deserialize<Dictionary<string, object>>(current); }
            catch { return null; }
        }
        if (doc == null) return null;
        object usersObj;
        if (!doc.TryGetValue("users", out usersObj) || !(usersObj is ArrayList)) return null;
        foreach (var u in (ArrayList)usersObj)
        {
            var d = u as IDictionary<string, object>;
            if (d == null) continue;
            string n = d.ContainsKey("name") ? (d["name"] ?? "").ToString() : "";
            if (string.Equals(n, name, StringComparison.OrdinalIgnoreCase)) return d;
        }
        return null;
    }

    private static string Sha256B64(string s)
    {
        using (var sha = SHA256.Create())
        {
            byte[] h = sha.ComputeHash(Encoding.UTF8.GetBytes(s));
            return Convert.ToBase64String(h);
        }
    }

    // Constant-time string compare. Stops timing attacks where the
    // attacker measures how long a wrong password takes to reject and
    // narrows down the correct prefix character by character.
    private static bool ConstantTimeEquals(string a, string b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;
        int diff = 0;
        for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }

    private static JavaScriptSerializer NewSerializer()
    {
        return new JavaScriptSerializer { MaxJsonLength = 16 * 1024 * 1024 };
    }

    private static string JsonEscape(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\n", "\\n").Replace("\r", "");
    }
}
