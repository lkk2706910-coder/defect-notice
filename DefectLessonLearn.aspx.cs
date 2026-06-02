using System;
using System.IO;
using System.Web;

public partial class DefectLessonLearn : System.Web.UI.Page
{
    private const string DataRelPath = "~/App_Data/defect_lessons.json";

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

        string path = Server.MapPath(DataRelPath);
        string dir = Path.GetDirectoryName(path);

        try
        {
            if (string.Equals(op, "list", StringComparison.OrdinalIgnoreCase))
            {
                if (!File.Exists(path))
                {
                    Response.Write("{\"cases\":[]}");
                }
                else
                {
                    Response.Write(File.ReadAllText(path, System.Text.Encoding.UTF8));
                }
            }
            else if (string.Equals(op, "save", StringComparison.OrdinalIgnoreCase))
            {
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                string body;
                using (var reader = new StreamReader(Request.InputStream, System.Text.Encoding.UTF8))
                {
                    body = reader.ReadToEnd();
                }
                if (string.IsNullOrWhiteSpace(body))
                {
                    Response.StatusCode = 400;
                    Response.Write("{\"ok\":false,\"error\":\"empty body\"}");
                }
                else
                {
                    // Atomic write: write to .tmp then replace
                    string tmp = path + ".tmp";
                    File.WriteAllText(tmp, body, new System.Text.UTF8Encoding(false));
                    if (File.Exists(path)) File.Delete(path);
                    File.Move(tmp, path);
                    Response.Write("{\"ok\":true}");
                }
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
            Response.Write("{\"ok\":false,\"error\":\"" + Escape(ex.Message) + "\"}");
        }

        Response.End();
    }

    private static string Escape(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }
}
