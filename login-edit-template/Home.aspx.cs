using System;
using System.IO;
using System.Web;
using System.Web.UI;

// Sample protected page showing the auth helper in action.
//
// Routes:
//   GET  Home.aspx                     -> renders the page (no auth needed
//                                         for the shell -- the JS asks the
//                                         user to log in before editing)
//   POST Home.aspx?op=login            -> verify credentials, issue token
//   GET  Home.aspx?op=whoami           -> who am I? (RequireAuth)
//   POST Home.aspx?op=save&id=...      -> mutating example (RequireEditor)
//
// All auth logic lives in App_Code/AuthHelper.cs. This file just routes.
public partial class Home : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string op = Request.QueryString["op"];
        if (string.IsNullOrEmpty(op)) return; // Just render the page.

        Response.ContentType = "application/json; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        string pageDir = Path.GetDirectoryName(Request.PhysicalPath);
        try
        {
            if (string.Equals(op, "login", StringComparison.OrdinalIgnoreCase))
            {
                AuthHelper.HandleLogin(HttpContext.Current, pageDir);
            }
            else if (string.Equals(op, "whoami", StringComparison.OrdinalIgnoreCase))
            {
                if (!AuthHelper.RequireAuth(HttpContext.Current)) { Response.End(); return; }
                Response.Write("{\"ok\":true,\"name\":\"" +
                    JsonEscape(AuthHelper.CurrentUser(HttpContext.Current)) +
                    "\",\"role\":\"" +
                    AuthHelper.CurrentRole(HttpContext.Current) + "\"}");
            }
            else if (string.Equals(op, "save", StringComparison.OrdinalIgnoreCase))
            {
                // Example mutating op. Replace with your real save logic.
                if (!AuthHelper.RequireEditor(HttpContext.Current)) { Response.End(); return; }
                Response.Write("{\"ok\":true,\"editedBy\":\"" +
                    JsonEscape(AuthHelper.CurrentUser(HttpContext.Current)) + "\"}");
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

    private static string JsonEscape(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\n", "\\n").Replace("\r", "");
    }
}
