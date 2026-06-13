using System;
using System.Web;
using System.Web.UI;

public partial class Login : Page
{
    // Bound to the <%= ErrorCode %> spot in Login.aspx, which maps it to
    // a Chinese user-facing string.  We deliberately keep this .cs ASCII-only.
    protected string ErrorCode = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Already logged in? Skip the form and go home.
        if (AuthHelper.ReadCurrent() != null)
        {
            Response.Redirect("Home.aspx", true);
            return;
        }

        if (!string.Equals(Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase)) return;

        string user = (Request.Form["username"] ?? "").Trim();
        string pwd  = Request.Form["password"] ?? "";
        var result = AuthHelper.TryLogin(user, pwd);
        if (!result.Ok)
        {
            ErrorCode = result.ErrorCode ?? "bad_credentials";
            return;
        }
        AuthHelper.SetCookie(Response, result.Token);
        Response.Redirect("Home.aspx", true);
    }
}
