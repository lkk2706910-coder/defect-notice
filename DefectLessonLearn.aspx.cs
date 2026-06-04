using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

public partial class DefectLessonLearn : System.Web.UI.Page
{
    // File location relative to the .aspx page's own folder (NOT the /PoC app root).
    // Resolved via Request.PhysicalPath so this works whether or not the folder
    // is configured as an IIS Application of its own.
    private const string DataFileName = "App_Data\\defect_lessons.json";

    // Lock object guarding the JSON file across concurrent requests.
    // ASP.NET serves multiple requests in parallel threads but they share this
    // AppDomain, so a static lock + atomic write is enough for one machine.
    private static readonly object _fileLock = new object();

    private string GetDataFilePath()
    {
        string pageDir = Path.GetDirectoryName(Request.PhysicalPath);
        return Path.Combine(pageDir, DataFileName);
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
                // Legacy whole-file replace (still works; clobbers concurrent edits)
                HandleSave(path, dir);
            }
            else if (string.Equals(op, "upsert", StringComparison.OrdinalIgnoreCase))
            {
                HandleUpsert(path, dir);
            }
            else if (string.Equals(op, "delete", StringComparison.OrdinalIgnoreCase))
            {
                HandleDelete(path);
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
