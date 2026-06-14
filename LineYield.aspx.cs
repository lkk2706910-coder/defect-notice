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

public partial class LineYield : System.Web.UI.Page
{
    // Two datasets share the same page.  The client picks one per request
    // via ?ds=light (default) or ?ds=bulk (the inherited lesson-learn data).
    // Each dataset has its own data file and its own backup-mirror file
    // inside App_Data\backup\.
    private const string DataFileLight = "App_Data\\Line_Yield.json";
    private const string DataFileBulk  = "App_Data\\Lesson_Learn.json";
    private const string UsersFileName = "App_Data\\users.json";

    private static readonly object _fileLock = new object();
    private static readonly object _usersLock = new object();

    // Auth tokens issued by HandleLogin live here. Sliding 8-hour expiry,
    // GC'd whenever a new login happens so the dictionary never grows
    // without bound. Always returning HTTP 200 from RequireAuth keeps
    // IIS Classic from tacking on WWW-Authenticate.
    private class TokenInfo { public string Name; public string Role; public DateTime ExpiresAt; }
    private static readonly object _tokenLock = new object();
    private static readonly Dictionary<string, TokenInfo> _tokens =
        new Dictionary<string, TokenInfo>(StringComparer.Ordinal);
    private const int TokenLifetimeHours = 8;

    // Resolve which dataset file this request is hitting based on the
    // ?ds= query parameter.  Anything other than "bulk" falls back to
    // "light" so a missing parameter never crashes the legacy callers.
    private string GetDatasetKey()
    {
        string ds = Request.QueryString["ds"];
        return string.Equals(ds, "bulk", StringComparison.OrdinalIgnoreCase) ? "bulk" : "light";
    }
    private string GetDataFilePath()
    {
        string pageDir = Path.GetDirectoryName(Request.PhysicalPath);
        string fileName = GetDatasetKey() == "bulk" ? DataFileBulk : DataFileLight;
        return Path.Combine(pageDir, fileName);
    }
    private string GetBackupFileName()
    {
        return GetDatasetKey() == "bulk" ? "Lesson_Learn_backup.json" : "Line_Yield_backup.json";
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
            // Login is the only op that never requires a prior token.
            if (string.Equals(op, "login", StringComparison.OrdinalIgnoreCase))
            {
                HandleLogin();
            }
            else if (string.Equals(op, "list", StringComparison.OrdinalIgnoreCase))
            {
                if (RequireAuth()) HandleList(path);
            }
            else if (string.Equals(op, "save", StringComparison.OrdinalIgnoreCase))
            {
                // Legacy whole-file replace (still works; clobbers concurrent edits)
                if (RequireEditor()) HandleSave(path, dir);
            }
            else if (string.Equals(op, "upsert", StringComparison.OrdinalIgnoreCase))
            {
                if (RequireEditor()) HandleUpsert(path, dir);
            }
            else if (string.Equals(op, "delete", StringComparison.OrdinalIgnoreCase))
            {
                if (RequireEditor()) HandleDelete(path);
            }
            else if (string.Equals(op, "chat", StringComparison.OrdinalIgnoreCase))
            {
                if (RequireAuth()) HandleChat();
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
        // Parse so we can stamp meta even on whole-file replace.
        var ser = NewSerializer();
        Dictionary<string, object> doc;
        try { doc = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>(); }
        catch { doc = new Dictionary<string, object>(); }
        var allIds = new List<string>();
        ArrayList allCases = GetCasesArray(doc);
        foreach (var c in allCases)
        {
            var d = c as IDictionary<string, object>;
            if (d != null && d.ContainsKey("id")) allIds.Add((d["id"] ?? "").ToString());
        }
        StampMeta(doc, ReadEditedBy(), allIds);
        lock (_fileLock)
        {
            WriteAtomicWithBackup(path, ser.Serialize(doc));
        }
        AppendAuditLog(ReadEditedBy(), "whole_save", allIds, null);
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

        string editedBy = ReadEditedBy();
        IDictionary<string, object> prevSnapshot = null;

        lock (_fileLock)
        {
            Dictionary<string, object> doc = ReadDoc(path, ser);
            ArrayList cases = GetCasesArray(doc);

            bool found = false;
            for (int i = 0; i < cases.Count; i++)
            {
                if (CaseIdEquals(cases[i], id))
                {
                    // Snapshot the OLD row before overwriting so the audit log
                    // can carry the previous state (lets us undo a bad edit).
                    prevSnapshot = cases[i] as IDictionary<string, object>;
                    cases[i] = incoming;
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                cases.Insert(0, incoming);
            }
            StampMeta(doc, editedBy, new List<string> { id });
            WriteAtomicWithBackup(path, ser.Serialize(doc));
        }
        var snaps = new List<IDictionary<string, object>>();
        if (prevSnapshot != null) snaps.Add(prevSnapshot);
        AppendAuditLog(editedBy, "upsert", new List<string> { id }, snaps);
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
        string editedBy = ReadEditedBy();
        var deletedSnapshots = new List<IDictionary<string, object>>();
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
                    // Keep the deleted row in the audit log so it can be
                    // restored if the delete was accidental.
                    var d = cases[i] as IDictionary<string, object>;
                    if (d != null) deletedSnapshots.Add(d);
                    cases.RemoveAt(i);
                }
            }
            StampMeta(doc, editedBy, new List<string> { id });
            WriteAtomicWithBackup(path, ser.Serialize(doc));
        }
        AppendAuditLog(editedBy, "delete", new List<string> { id }, deletedSnapshots);
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

    // ---- Local-style edit-mode auth ----
    // No tokens, no per-request enforcement: this endpoint just answers
    // "is this username+password correct?" so the UI can lock/unlock its
    // edit mode locally. Storage backend is App_Data\users.json with the
    // same {name, salt, hash} shape the Python user_hash.py tool writes.
    // Always returns HTTP 200 (never 401), so IIS Classic mode cannot
    // tack a WWW-Authenticate header onto the response.
    private void HandleLogin()
    {
        string body = ReadBody();
        var ser = NewSerializer();
        Dictionary<string, object> req;
        try
        {
            req = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>();
        }
        catch
        {
            Response.Write("{\"ok\":false,\"error\":\"invalid_json\"}");
            return;
        }
        string name = req.ContainsKey("username") ? (req["username"] ?? "").ToString().Trim() : "";
        string pwd  = req.ContainsKey("password") ? (req["password"] ?? "").ToString() : "";
        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(pwd))
        {
            Response.Write("{\"ok\":false,\"error\":\"empty_fields\"}");
            return;
        }

        var user = LoadUser(name);
        bool ok = false;
        if (user != null)
        {
            string salt = user.ContainsKey("salt") ? (user["salt"] ?? "").ToString() : "";
            string expectedHash = user.ContainsKey("hash") ? (user["hash"] ?? "").ToString() : "";
            string computed = Sha256B64(salt + pwd);
            ok = !string.IsNullOrEmpty(expectedHash) && ConstantTimeEquals(expectedHash, computed);
        }

        if (ok)
        {
            // Default role is editor for users.json entries written before
            // the role field existed, so existing accounts keep their old
            // privileges. Explicit value must be "editor" or "viewer".
            string role = "editor";
            if (user.ContainsKey("role"))
            {
                string r = (user["role"] ?? "").ToString().Trim().ToLowerInvariant();
                if (r == "viewer" || r == "editor") role = r;
            }
            string token = NewToken();
            lock (_tokenLock)
            {
                // GC expired tokens on each successful login so the dict can't grow forever.
                var now = DateTime.UtcNow;
                var dead = new List<string>();
                foreach (var kv in _tokens) if (kv.Value.ExpiresAt < now) dead.Add(kv.Key);
                foreach (var k in dead) _tokens.Remove(k);

                _tokens[token] = new TokenInfo { Name = name, Role = role, ExpiresAt = now.AddHours(TokenLifetimeHours) };
            }
            Response.Write("{\"ok\":true,\"name\":\"" + JsonEscape(name) + "\",\"role\":\"" + role + "\",\"token\":\"" + JsonEscape(token) + "\"}");
        }
        else
        {
            Response.Write("{\"ok\":false,\"error\":\"bad_credentials\"}");
        }
    }

    // Gate for every protected op. Reads X-Auth-Token, looks it up in the
    // in-memory token table, applies sliding expiry. Writes a 200 JSON
    // failure (never 401) so IIS Classic mode does not invent a
    // WWW-Authenticate challenge on our behalf.
    private bool RequireAuth()
    {
        string token = Request.Headers["X-Auth-Token"];
        if (string.IsNullOrEmpty(token))
        {
            Response.Write("{\"ok\":false,\"error\":\"needLogin\"}");
            return false;
        }
        TokenInfo info;
        lock (_tokenLock)
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
            // Sliding expiry: any successful request extends the session.
            info.ExpiresAt = DateTime.UtcNow.AddHours(TokenLifetimeHours);
        }
        // Stash the username so audit logging downstream can pick it up
        // without re-reading the header.
        HttpContext.Current.Items["AuthUser"] = info.Name;
        HttpContext.Current.Items["AuthRole"] = info.Role ?? "editor";
        return true;
    }

    // Gate for mutating ops. Viewer-role tokens are accepted by RequireAuth
    // (they can read) but rejected here so they cannot mutate the table.
    private bool RequireEditor()
    {
        if (!RequireAuth()) return false;
        string role = (HttpContext.Current.Items["AuthRole"] ?? "editor").ToString();
        if (role != "editor")
        {
            Response.Write("{\"ok\":false,\"error\":\"readonly\"}");
            return false;
        }
        return true;
    }

    private static string NewToken()
    {
        byte[] buf = new byte[24];
        using (var rng = System.Security.Cryptography.RandomNumberGenerator.Create())
        {
            rng.GetBytes(buf);
        }
        return Convert.ToBase64String(buf).Replace("/", "_").Replace("+", "-").Replace("=", "");
    }

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

    private static bool ConstantTimeEquals(string a, string b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;
        int diff = 0;
        for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
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

    // ---- Last-edit metadata + backup + audit log ----
    // Prefer the username pulled from the auth token (set by RequireAuth on
    // Items["AuthUser"]) so an audit entry can't be spoofed via a forged
    // X-Edit-User header. Falls back to the header only when no token was
    // checked (legacy / direct save path).
    private string ReadEditedBy()
    {
        object cached = HttpContext.Current.Items["AuthUser"];
        if (cached != null && !string.IsNullOrEmpty(cached.ToString())) return cached.ToString();
        string raw = Request.Headers["X-Edit-User"];
        if (raw == null) return "";
        return raw.Trim();
    }

    // Stamp the doc with "who last touched it and what they touched", so the
    // UI can display it without a separate API call.
    private static void StampMeta(Dictionary<string, object> doc, string editedBy, IList<string> affectedIds)
    {
        var meta = new Dictionary<string, object>();
        meta["lastEditedAt"] = DateTime.UtcNow.ToString("o"); // ISO 8601 / RFC3339
        meta["lastEditedBy"] = editedBy ?? "";
        var arr = new ArrayList();
        if (affectedIds != null) foreach (var id in affectedIds) arr.Add(id);
        meta["lastEditedCaseIds"] = arr;
        doc["_meta"] = meta;
    }

    // Atomic write to main, then mirror the same content to App_Data\backup
    // so a corrupt App_Data folder is not the only copy of the data.
    private void WriteAtomicWithBackup(string path, string content)
    {
        WriteAtomic(path, content);
        try
        {
            string backupDir = Path.Combine(Path.GetDirectoryName(path), "backup");
            if (!Directory.Exists(backupDir)) Directory.CreateDirectory(backupDir);
            // Each dataset has its own backup mirror so they don't clobber
            // each other when both are being edited.
            WriteAtomic(Path.Combine(backupDir, GetBackupFileName()), content);
        }
        catch { /* backup failure must not block the main save */ }
    }

    // Append-only audit trail in App_Data\backup\edit_history_YYYY-MM.jsonl
    // One JSON object per line: {at, by, op, ids, snapshots?}.
    // File naming partitions by UTC year/month -- every save lands in the
    // file matching the entry's own "at" timestamp, so months become
    // self-contained archives (rename / move / delete one month without
    // touching the others). The same UtcNow value is used for both the
    // filename and the entry timestamp so a save right at the month
    // boundary stays consistent.
    // 'snapshots' carries the BEFORE state for upsert (so an edit can be
    // reverted) and the full deleted case body for delete (so it can be
    // restored). Both intentionally omitted for "whole_save" to keep the
    // log small; the rolling backup file covers that case.
    private static readonly object _logLock = new object();
    private void AppendAuditLog(string by, string op, IList<string> ids, IList<IDictionary<string, object>> snapshots)
    {
        try
        {
            string logDir = Path.Combine(Path.GetDirectoryName(GetDataFilePath()), "backup");
            DateTime now = DateTime.UtcNow;
            var entry = new Dictionary<string, object>();
            entry["at"] = now.ToString("o");
            entry["by"] = by ?? "";
            entry["ds"] = GetDatasetKey();   // which dataset the edit happened in
            entry["op"] = op;
            var idArr = new ArrayList();
            if (ids != null) foreach (var id in ids) idArr.Add(id);
            entry["ids"] = idArr;
            if (snapshots != null && snapshots.Count > 0)
            {
                var snapArr = new ArrayList();
                foreach (var s in snapshots) snapArr.Add(s);
                entry["snapshots"] = snapArr;
            }
            string line = NewSerializer().Serialize(entry) + "\n";
            string fileName = "edit_history_" + now.ToString("yyyy-MM") + ".jsonl";
            lock (_logLock)
            {
                if (!Directory.Exists(logDir)) Directory.CreateDirectory(logDir);
                File.AppendAllText(Path.Combine(logDir, fileName),
                    line, new System.Text.UTF8Encoding(false));
            }
        }
        catch { /* audit failure must not block the main save */ }
    }

    private static string JsonEscape(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }
}
