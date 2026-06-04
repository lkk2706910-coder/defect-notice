using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

public partial class DefectLessonLearn : System.Web.UI.Page
{
    private const string DataFileName = "App_Data\\defect_lessons.json";
    private const string UsersFileName = "App_Data\\users.json";

    private static readonly object _fileLock = new object();
    private static readonly object _usersLock = new object();

    // ---- In-memory auth state (lives for the AppDomain) ----
    private class TokenInfo { public string Name; public DateTime ExpiresAt; }
    private class FailureInfo { public int Count; public DateTime LockedUntil; }
    private static readonly Dictionary<string, TokenInfo> _tokens = new Dictionary<string, TokenInfo>(StringComparer.Ordinal);
    private static readonly Dictionary<string, FailureInfo> _failures = new Dictionary<string, FailureInfo>(StringComparer.OrdinalIgnoreCase);

    private string GetDataFilePath()
    {
        string pageDir = Path.GetDirectoryName(Request.PhysicalPath);
        return Path.Combine(pageDir, DataFileName);
    }
    private string GetUsersFilePath()
    {
        string pageDir = Path.GetDirectoryName(Request.PhysicalPath);
        return Path.Combine(pageDir, UsersFileName);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string op = Request.QueryString["op"];
        if (!string.IsNullOrEmpty(op))
        {
            HandleApi(op);
        }
    }

    private void HandleApi(string op)
    {
        Response.ContentType = "application/json; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);

        string path = GetDataFilePath();
        string dir = Path.GetDirectoryName(path);

        try
        {
            if (string.Equals(op, "list", StringComparison.OrdinalIgnoreCase))
            {
                HandleList(path);
            }
            else if (string.Equals(op, "save", StringComparison.OrdinalIgnoreCase))
            {
                if (!RequireAuth()) return;
                HandleSave(path, dir);
            }
            else if (string.Equals(op, "upsert", StringComparison.OrdinalIgnoreCase))
            {
                if (!RequireAuth()) return;
                HandleUpsert(path, dir);
            }
            else if (string.Equals(op, "delete", StringComparison.OrdinalIgnoreCase))
            {
                if (!RequireAuth()) return;
                HandleDelete(path);
            }
            else if (string.Equals(op, "chat", StringComparison.OrdinalIgnoreCase))
            {
                HandleChat();
            }
            else if (string.Equals(op, "login", StringComparison.OrdinalIgnoreCase))
            {
                HandleLogin();
            }
            else if (string.Equals(op, "logout", StringComparison.OrdinalIgnoreCase))
            {
                HandleLogout();
            }
            else if (string.Equals(op, "whoami", StringComparison.OrdinalIgnoreCase))
            {
                HandleWhoami();
            }
            else if (string.Equals(op, "admin_add_user", StringComparison.OrdinalIgnoreCase))
            {
                HandleAdminAddUser();
            }
            else
            {
                Response.StatusCode = 400;
                Response.Write("{\"ok\":false,\"error\":\"unknown op\"}");
            }
        }
        catch (Exception ex)
        {
            Response.StatusCode = 500;
            Response.Write("{\"ok\":false,\"error\":\"" + JsonEscape(ex.Message) + "\"}");
        }
        Response.End();
    }

    private void HandleList(string path)
    {
        lock (_fileLock)
        {
            if (!File.Exists(path))
            {
                Response.Write("{\"cases\":[],\"_debug_path\":\"" + JsonEscape(path) + "\"}");
            }
            else
            {
                Response.Write(File.ReadAllText(path, System.Text.Encoding.UTF8));
            }
        }
    }

    private void HandleSave(string path, string dir)
    {
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        string body = ReadBody();
        if (string.IsNullOrWhiteSpace(body))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"empty body\"}");
            return;
        }
        lock (_fileLock)
        {
            WriteAtomic(path, body);
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandleUpsert(string path, string dir)
    {
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        string body = ReadBody();
        if (string.IsNullOrWhiteSpace(body))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"empty body\"}");
            return;
        }

        var ser = NewSerializer();
        Dictionary<string, object> incoming;
        try
        {
            incoming = ser.Deserialize<Dictionary<string, object>>(body);
        }
        catch
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"invalid json\"}");
            return;
        }
        if (incoming == null || !incoming.ContainsKey("id"))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"missing id\"}");
            return;
        }
        string id = (incoming["id"] ?? "").ToString();
        if (string.IsNullOrEmpty(id))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"empty id\"}");
            return;
        }

        lock (_fileLock)
        {
            Dictionary<string, object> doc = ReadDoc(path, ser);
            ArrayList cases = GetCasesArray(doc);

            bool found = false;
            for (int i = 0; i < cases.Count; i++)
            {
                if (CaseIdEquals(cases[i], id))
                {
                    cases[i] = incoming;
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                cases.Insert(0, incoming);
            }
            WriteAtomic(path, ser.Serialize(doc));
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandleDelete(string path)
    {
        string id = Request.QueryString["id"];
        if (string.IsNullOrEmpty(id))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"missing id\"}");
            return;
        }
        var ser = NewSerializer();
        lock (_fileLock)
        {
            if (!File.Exists(path))
            {
                Response.Write("{\"ok\":true,\"_note\":\"file not exists\"}");
                return;
            }
            Dictionary<string, object> doc = ReadDoc(path, ser);
            ArrayList cases = GetCasesArray(doc);
            for (int i = cases.Count - 1; i >= 0; i--)
            {
                if (CaseIdEquals(cases[i], id))
                {
                    cases.RemoveAt(i);
                }
            }
            WriteAtomic(path, ser.Serialize(doc));
        }
        Response.Write("{\"ok\":true}");
    }

    // ---- AI assistant proxy ----
    // Client posts { messages: [{role, content}, ...] }.
    // We prepend the configured system prompt and forward to the LLM gateway,
    // keeping the api-key on the server so it never reaches the browser.
    private void HandleChat()
    {
        string url = ConfigurationManager.AppSettings["AiGatewayUrl"];
        string apiKey = ConfigurationManager.AppSettings["AiApiKey"];
        string userId = ConfigurationManager.AppSettings["AiUserId"];
        string systemPrompt = ConfigurationManager.AppSettings["AiSystemPrompt"];
        // Fallback prompt kept ASCII-only so this source file is encoding-safe.
        // The real Chinese prompt lives in web.config (<appSettings AiSystemPrompt>).
        if (string.IsNullOrEmpty(systemPrompt)) systemPrompt = "You are a helpful assistant.";

        if (string.IsNullOrEmpty(url) || string.IsNullOrEmpty(apiKey))
        {
            Response.StatusCode = 500;
            Response.Write("{\"ok\":false,\"error\":\"AiGatewayUrl / AiApiKey not configured in web.config\"}");
            return;
        }

        string body = ReadBody();
        var ser = NewSerializer();
        Dictionary<string, object> clientReq;
        try
        {
            clientReq = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>();
        }
        catch
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"invalid json\"}");
            return;
        }

        // Build the message list: system prompt first, then whatever the client sent.
        var messages = new ArrayList();
        messages.Add(new Dictionary<string, object> {
            { "role", "system" },
            { "content", systemPrompt }
        });
        object clientMessages;
        if (clientReq.TryGetValue("messages", out clientMessages) && clientMessages is ArrayList)
        {
            foreach (var m in (ArrayList)clientMessages)
            {
                if (m != null) messages.Add(m);
            }
        }

        var payload = new Dictionary<string, object> { { "messages", messages } };
        byte[] payloadBytes = System.Text.Encoding.UTF8.GetBytes(ser.Serialize(payload));

        // Allow plain HTTP to a non-DNS internal IP without strict cert/SNI hassles.
        var req = (HttpWebRequest)WebRequest.Create(url);
        req.Method = "POST";
        req.Accept = "*/*";
        req.ContentType = "application/json";
        req.Headers["api-key"] = apiKey;
        if (!string.IsNullOrEmpty(userId)) req.Headers["user-id"] = userId;
        req.Timeout = 120000;          // 2 min: LLM responses can be slow
        req.ReadWriteTimeout = 120000;
        req.ContentLength = payloadBytes.Length;

        try
        {
            using (var s = req.GetRequestStream()) s.Write(payloadBytes, 0, payloadBytes.Length);
            using (var resp = (HttpWebResponse)req.GetResponse())
            using (var sr = new StreamReader(resp.GetResponseStream(), System.Text.Encoding.UTF8))
            {
                Response.Write(sr.ReadToEnd());
            }
        }
        catch (WebException wex)
        {
            string detail = "";
            int status = 502;
            var httpResp = wex.Response as HttpWebResponse;
            if (httpResp != null)
            {
                status = (int)httpResp.StatusCode;
                try
                {
                    using (var sr = new StreamReader(httpResp.GetResponseStream(), System.Text.Encoding.UTF8))
                        detail = sr.ReadToEnd();
                }
                catch { }
            }
            Response.StatusCode = status;
            Response.Write("{\"ok\":false,\"error\":\"" + JsonEscape(wex.Message) + "\",\"detail\":" + ser.Serialize(detail) + "}");
        }
    }

    // ---- Auth: login / logout / whoami / admin add user ----
    // Gate function used by every mutating op. Reads X-Auth-Token header,
    // looks it up in the in-memory token table, applies expiry. When auth
    // fails we deliberately keep the HTTP status at 200 — sending 401 here
    // lets IIS bolt on a WWW-Authenticate header that triggers a native
    // browser sign-in popup we have no way to disable from app code. The
    // client checks the JSON body for {ok:false, error:"needLogin"} instead.
    private bool RequireAuth()
    {
        string token = Request.Headers["X-Auth-Token"];
        if (string.IsNullOrEmpty(token))
        {
            Response.Write("{\"ok\":false,\"error\":\"needLogin\"}");
            return false;
        }
        TokenInfo info;
        lock (_tokens)
        {
            if (!_tokens.TryGetValue(token, out info))
            {
                Response.Write("{\"ok\":false,\"error\":\"needLogin\"}");
                return false;
            }
            if (info.ExpiresAt < DateTime.UtcNow)
            {
                _tokens.Remove(token);
                Response.Write("{\"ok\":false,\"error\":\"needLogin\"}");
                return false;
            }
        }
        HttpContext.Current.Items["AuthUser"] = info.Name;
        return true;
    }

    private void HandleLogin()
    {
        Response.TrySkipIisCustomErrors = true;
        Response.Headers.Remove("WWW-Authenticate");
        string body = ReadBody();
        var ser = NewSerializer();
        Dictionary<string, object> req;
        try { req = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>(); }
        catch
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"invalid json\"}");
            return;
        }
        string name = req.ContainsKey("username") ? (req["username"] ?? "").ToString().Trim() : "";
        string pwd = req.ContainsKey("password") ? (req["password"] ?? "").ToString() : "";
        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(pwd))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"username and password required\"}");
            return;
        }

        // Lockout check: 5 failures within window -> blocked for N minutes.
        int maxAttempts = ConfigGetInt("LoginMaxAttempts", 5);
        int lockMinutes = ConfigGetInt("LoginLockMinutes", 1);
        lock (_failures)
        {
            FailureInfo fi;
            if (_failures.TryGetValue(name, out fi) && fi.LockedUntil > DateTime.UtcNow)
            {
                int waitSec = (int)Math.Ceiling((fi.LockedUntil - DateTime.UtcNow).TotalSeconds);
                // Keep HTTP 200 — see RequireAuth() for why we don't use 4xx here.
                Response.Write("{\"ok\":false,\"error\":\"locked\",\"retryAfter\":" + waitSec + "}");
                return;
            }
        }

        // Load users.json and verify hash
        var user = LoadUser(name);
        bool ok = false;
        if (user != null)
        {
            string salt = user.ContainsKey("salt") ? (user["salt"] ?? "").ToString() : "";
            string expectedHash = user.ContainsKey("hash") ? (user["hash"] ?? "").ToString() : "";
            string computed = Sha256B64(salt + pwd);
            ok = !string.IsNullOrEmpty(expectedHash) && ConstantTimeEquals(expectedHash, computed);
        }

        if (!ok)
        {
            // Record failure, lock after N attempts.
            lock (_failures)
            {
                FailureInfo fi;
                if (!_failures.TryGetValue(name, out fi)) { fi = new FailureInfo(); _failures[name] = fi; }
                fi.Count++;
                if (fi.Count >= maxAttempts)
                {
                    fi.LockedUntil = DateTime.UtcNow.AddMinutes(lockMinutes);
                    fi.Count = 0;
                }
            }
            // Keep HTTP 200 — see RequireAuth() for the IIS-popup reason.
            Response.Write("{\"ok\":false,\"error\":\"bad_credentials\"}");
            return;
        }

        // Success - reset failure count, issue token
        lock (_failures) { _failures.Remove(name); }

        int hours = ConfigGetInt("SessionHours", 8);
        string token = NewToken();
        lock (_tokens)
        {
            // Garbage-collect any tokens that have expired so the table doesn't grow forever.
            var expired = new List<string>();
            foreach (var kv in _tokens) if (kv.Value.ExpiresAt < DateTime.UtcNow) expired.Add(kv.Key);
            foreach (var k in expired) _tokens.Remove(k);

            _tokens[token] = new TokenInfo { Name = name, ExpiresAt = DateTime.UtcNow.AddHours(hours) };
        }
        Response.Write("{\"ok\":true,\"token\":\"" + JsonEscape(token) + "\",\"name\":\"" + JsonEscape(name) + "\",\"expiresInHours\":" + hours + "}");
    }

    private void HandleLogout()
    {
        string token = Request.Headers["X-Auth-Token"];
        if (!string.IsNullOrEmpty(token))
        {
            lock (_tokens) { _tokens.Remove(token); }
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandleWhoami()
    {
        if (!RequireAuth()) return;
        string name = (HttpContext.Current.Items["AuthUser"] ?? "").ToString();
        Response.Write("{\"ok\":true,\"name\":\"" + JsonEscape(name) + "\"}");
    }

    // Admin endpoint to bootstrap / add / replace users. Requires AdminKey
    // from web.config (separate secret, never sent from the page UI).
    private void HandleAdminAddUser()
    {
        string adminKey = ConfigurationManager.AppSettings["AdminKey"];
        if (string.IsNullOrEmpty(adminKey))
        {
            Response.StatusCode = 503;
            Response.Write("{\"ok\":false,\"error\":\"AdminKey not configured in web.config\"}");
            return;
        }
        string body = ReadBody();
        var ser = NewSerializer();
        Dictionary<string, object> req;
        try { req = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>(); }
        catch
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"invalid json\"}");
            return;
        }
        string givenKey = req.ContainsKey("adminKey") ? (req["adminKey"] ?? "").ToString() : "";
        if (!ConstantTimeEquals(adminKey, givenKey))
        {
            // Keep HTTP 200 — see RequireAuth() for the IIS-popup reason.
            Response.Write("{\"ok\":false,\"error\":\"bad adminKey\"}");
            return;
        }
        string name = req.ContainsKey("username") ? (req["username"] ?? "").ToString().Trim() : "";
        string pwd  = req.ContainsKey("password") ? (req["password"] ?? "").ToString() : "";
        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(pwd))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"username and password required\"}");
            return;
        }
        string salt = NewToken().Substring(0, 16);
        string hash = Sha256B64(salt + pwd);
        UpsertUser(name, salt, hash);
        Response.Write("{\"ok\":true,\"name\":\"" + JsonEscape(name) + "\"}");
    }

    // ---- users.json helpers ----
    private IDictionary<string, object> LoadUser(string name)
    {
        string path = GetUsersFilePath();
        if (!File.Exists(path)) return null;
        var ser = NewSerializer();
        Dictionary<string, object> doc;
        lock (_usersLock)
        {
            string current = File.ReadAllText(path, Encoding.UTF8);
            if (string.IsNullOrWhiteSpace(current)) return null;
            doc = ser.Deserialize<Dictionary<string, object>>(current);
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
    private void UpsertUser(string name, string salt, string hash)
    {
        string path = GetUsersFilePath();
        string dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        var ser = NewSerializer();
        lock (_usersLock)
        {
            Dictionary<string, object> doc;
            if (File.Exists(path))
            {
                string current = File.ReadAllText(path, Encoding.UTF8);
                doc = string.IsNullOrWhiteSpace(current)
                    ? new Dictionary<string, object>()
                    : (ser.Deserialize<Dictionary<string, object>>(current) ?? new Dictionary<string, object>());
            }
            else { doc = new Dictionary<string, object>(); }
            ArrayList users;
            object usersObj;
            if (doc.TryGetValue("users", out usersObj) && usersObj is ArrayList) users = (ArrayList)usersObj;
            else { users = new ArrayList(); doc["users"] = users; }

            bool found = false;
            for (int i = 0; i < users.Count; i++)
            {
                var d = users[i] as IDictionary<string, object>;
                if (d == null) continue;
                string n = d.ContainsKey("name") ? (d["name"] ?? "").ToString() : "";
                if (string.Equals(n, name, StringComparison.OrdinalIgnoreCase))
                {
                    users[i] = new Dictionary<string, object> { { "name", name }, { "salt", salt }, { "hash", hash } };
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                users.Add(new Dictionary<string, object> { { "name", name }, { "salt", salt }, { "hash", hash } });
            }
            WriteAtomic(path, ser.Serialize(doc));
        }
    }

    // ---- Crypto / config helpers ----
    private static string Sha256B64(string s)
    {
        using (var sha = SHA256.Create())
        {
            byte[] h = sha.ComputeHash(Encoding.UTF8.GetBytes(s));
            return Convert.ToBase64String(h);
        }
    }
    private static string NewToken()
    {
        byte[] buf = new byte[24];
        using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(buf);
        return Convert.ToBase64String(buf).Replace("/", "_").Replace("+", "-").Replace("=", "");
    }
    private static bool ConstantTimeEquals(string a, string b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;
        int diff = 0;
        for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }
    private static int ConfigGetInt(string key, int dflt)
    {
        string raw = ConfigurationManager.AppSettings[key];
        int v;
        if (int.TryParse(raw, out v) && v > 0) return v;
        return dflt;
    }

    // ---- Helpers ----

    private string ReadBody()
    {
        using (var reader = new StreamReader(Request.InputStream, System.Text.Encoding.UTF8))
        {
            return reader.ReadToEnd();
        }
    }

    private static JavaScriptSerializer NewSerializer()
    {
        // Allow very large bodies (base64-encoded images can easily exceed the default 2MB).
        return new JavaScriptSerializer { MaxJsonLength = 200 * 1024 * 1024 };
    }

    private static Dictionary<string, object> ReadDoc(string path, JavaScriptSerializer ser)
    {
        if (!File.Exists(path)) return new Dictionary<string, object>();
        string current = File.ReadAllText(path, System.Text.Encoding.UTF8);
        if (string.IsNullOrWhiteSpace(current)) return new Dictionary<string, object>();
        return ser.Deserialize<Dictionary<string, object>>(current) ?? new Dictionary<string, object>();
    }

    private static ArrayList GetCasesArray(Dictionary<string, object> doc)
    {
        object casesObj;
        if (doc.TryGetValue("cases", out casesObj) && casesObj is ArrayList)
        {
            return (ArrayList)casesObj;
        }
        var fresh = new ArrayList();
        doc["cases"] = fresh;
        return fresh;
    }

    private static bool CaseIdEquals(object caseObj, string id)
    {
        var dict = caseObj as IDictionary<string, object>;
        if (dict == null) return false;
        if (!dict.ContainsKey("id")) return false;
        return string.Equals((dict["id"] ?? "").ToString(), id, StringComparison.Ordinal);
    }

    private static void WriteAtomic(string path, string content)
    {
        string tmp = path + ".tmp";
        File.WriteAllText(tmp, content, new System.Text.UTF8Encoding(false));
        if (File.Exists(path)) File.Delete(path);
        File.Move(tmp, path);
    }

    private static string JsonEscape(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }
}
