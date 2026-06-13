using System;
using System.Collections.Generic;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web;

// Authentication helper, DB-backed.
// - Validates {username, password} against the Users table.
// - Issues a random token on success, stored in an HttpOnly cookie
//   so JavaScript on the page can never read it (defeats XSS theft).
// - Tokens live in an in-memory Dictionary with sliding expiry.
//   IIS recycle wipes them (everyone logs in again) -- acceptable
//   for an internal PoC.  Move to a Sessions DB table later if
//   you need session survival across recycles.
public static class AuthHelper
{
    public const string CookieName = "site_auth";

    private class TokenInfo
    {
        public string Username;
        public DateTime ExpiresAt;
    }

    private static readonly object _lock = new object();
    private static readonly Dictionary<string, TokenInfo> _tokens =
        new Dictionary<string, TokenInfo>(StringComparer.Ordinal);

    private static int SessionHours
    {
        get
        {
            int v;
            return int.TryParse(ConfigurationManager.AppSettings["SessionHours"], out v) && v > 0 ? v : 8;
        }
    }

    // Result of a login attempt.  When Ok = true, Token + Username
    // are populated and the caller should set the auth cookie.
    public class LoginResult
    {
        public bool Ok;
        public string Token;
        public string Username;
        public string ErrorCode;  // "bad_credentials" / "disabled" / "empty"
    }

    public static LoginResult TryLogin(string username, string password)
    {
        var result = new LoginResult();
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            result.ErrorCode = "empty";
            return result;
        }

        var row = DbHelper.QueryOne(
            "SELECT Username, Salt, PasswordHash, Enabled FROM Users WHERE Username = @p0",
            username
        );
        if (row == null)
        {
            result.ErrorCode = "bad_credentials";
            return result;
        }
        bool enabled = row.ContainsKey("Enabled") && row["Enabled"] is bool ? (bool)row["Enabled"] : true;
        if (!enabled)
        {
            result.ErrorCode = "disabled";
            return result;
        }
        string salt = (row["Salt"] ?? "").ToString();
        string expected = (row["PasswordHash"] ?? "").ToString();
        string computed = Sha256B64(salt + password);
        if (string.IsNullOrEmpty(expected) || !ConstantTimeEquals(expected, computed))
        {
            result.ErrorCode = "bad_credentials";
            return result;
        }

        string name = (row["Username"] ?? username).ToString();
        string token = NewToken();
        lock (_lock)
        {
            GcExpired();
            _tokens[token] = new TokenInfo
            {
                Username = name,
                ExpiresAt = DateTime.UtcNow.AddHours(SessionHours)
            };
        }
        // Best-effort last-login timestamp
        try
        {
            DbHelper.Execute("UPDATE Users SET LastLoginAt = SYSUTCDATETIME() WHERE Username = @p0", name);
        }
        catch { /* don't block login on this */ }

        result.Ok = true;
        result.Token = token;
        result.Username = name;
        return result;
    }

    // Read the cookie off the current request and look up the user.
    // Returns null when no valid session is attached.
    public class CurrentUser
    {
        public string Username;
    }
    public static CurrentUser ReadCurrent()
    {
        var req = HttpContext.Current.Request;
        var cookie = req.Cookies[CookieName];
        if (cookie == null || string.IsNullOrEmpty(cookie.Value)) return null;
        TokenInfo info;
        lock (_lock)
        {
            if (!_tokens.TryGetValue(cookie.Value, out info)) return null;
            if (info.ExpiresAt < DateTime.UtcNow)
            {
                _tokens.Remove(cookie.Value);
                return null;
            }
            // Sliding window: every successful auth extends the session.
            info.ExpiresAt = DateTime.UtcNow.AddHours(SessionHours);
        }
        return new CurrentUser { Username = info.Username };
    }

    public static void SetCookie(HttpResponse resp, string token)
    {
        var cookie = new HttpCookie(CookieName, token);
        cookie.HttpOnly = true;
        cookie.Path = "/";
        // Don't set Expires -> session cookie, cleared when browser closes.
        // (Server-side TokenInfo still enforces the 8-hour cap.)
        resp.Cookies.Add(cookie);
    }

    public static void ClearCookie(HttpResponse resp)
    {
        // Forget on the server side as well.
        var req = HttpContext.Current.Request;
        var c = req.Cookies[CookieName];
        if (c != null && !string.IsNullOrEmpty(c.Value))
        {
            lock (_lock) { _tokens.Remove(c.Value); }
        }
        var del = new HttpCookie(CookieName, "");
        del.Expires = DateTime.UtcNow.AddDays(-1);
        del.Path = "/";
        resp.Cookies.Add(del);
    }

    // ---- helpers ----

    private static void GcExpired()
    {
        var now = DateTime.UtcNow;
        var dead = new List<string>();
        foreach (var kv in _tokens) if (kv.Value.ExpiresAt < now) dead.Add(kv.Key);
        foreach (var k in dead) _tokens.Remove(k);
    }

    public static string Sha256B64(string s)
    {
        using (var sha = SHA256.Create())
        {
            byte[] h = sha.ComputeHash(Encoding.UTF8.GetBytes(s));
            return Convert.ToBase64String(h);
        }
    }

    public static string NewToken()
    {
        byte[] buf = new byte[24];
        using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(buf);
        return Convert.ToBase64String(buf).Replace("/", "_").Replace("+", "-").Replace("=", "");
    }

    public static string NewSalt()
    {
        byte[] buf = new byte[12];
        using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(buf);
        return Convert.ToBase64String(buf).Replace("/", "_").Replace("+", "-").Replace("=", "");
    }

    public static bool ConstantTimeEquals(string a, string b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;
        int diff = 0;
        for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }
}
