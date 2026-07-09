using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

// Protected home page + AI chat proxy.
//
// Routes:
//   GET  Home.aspx              -> renders the page (after auth check)
//   GET  Home.aspx?op=logout    -> clear session, redirect to Login
//   POST Home.aspx?op=chat      -> proxy to LLM (auth-gated)
//
// The page itself is rendered by Home.aspx markup; this code-behind
// only enforces auth and handles the API ops.
public partial class Home : Page
{
    protected string CurrentUsername = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Auth gate -- every request to this page requires a valid session.
        var me = AuthHelper.ReadCurrent();
        if (me == null)
        {
            // For API ops we answer in JSON; otherwise redirect to the login page.
            string op = Request.QueryString["op"];
            if (!string.IsNullOrEmpty(op))
            {
                Response.ContentType = "application/json; charset=utf-8";
                Response.Write("{\"ok\":false,\"error\":\"needLogin\"}");
                Response.End();
                return;
            }
            Response.Redirect("Login.aspx", true);
            return;
        }
        CurrentUsername = me.Username;

        string opStr = Request.QueryString["op"];
        if (string.Equals(opStr, "logout", StringComparison.OrdinalIgnoreCase))
        {
            AuthHelper.ClearCookie(Response);
            Response.Redirect("Login.aspx", true);
            return;
        }
        if (string.Equals(opStr, "chat", StringComparison.OrdinalIgnoreCase))
        {
            Response.ContentType = "application/json; charset=utf-8";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            try { HandleChat(); }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write("{\"ok\":false,\"error\":\"" + JsonEscape(ex.Message) + "\"}");
            }
            Response.End();
            return;
        }
        // Otherwise fall through to render the page.
    }

    private void HandleChat()
    {
        string url = ConfigurationManager.AppSettings["AiGatewayUrl"];
        string apiKey = ConfigurationManager.AppSettings["AiApiKey"];
        string userId = ConfigurationManager.AppSettings["AiUserId"];
        // New gateway routes by the "model" field in the JSON body instead of
        // a model name in the URL path. Configured via appSettings AiModel;
        // when it is empty we simply do not send the field.
        string model = ConfigurationManager.AppSettings["AiModel"];
        string systemPrompt = ConfigurationManager.AppSettings["AiSystemPrompt"];
        if (string.IsNullOrEmpty(systemPrompt)) systemPrompt = "You are a helpful assistant.";
        if (string.IsNullOrEmpty(url) || string.IsNullOrEmpty(apiKey))
        {
            Response.StatusCode = 500;
            Response.Write("{\"ok\":false,\"error\":\"AiGatewayUrl / AiApiKey not configured\"}");
            return;
        }

        string body;
        using (var sr = new StreamReader(Request.InputStream, Encoding.UTF8)) body = sr.ReadToEnd();
        var ser = new JavaScriptSerializer { MaxJsonLength = 200 * 1024 * 1024 };
        Dictionary<string, object> req;
        try { req = ser.Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>(); }
        catch
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"invalid json\"}");
            return;
        }

        var messages = new System.Collections.ArrayList();
        messages.Add(new Dictionary<string, object> { { "role", "system" }, { "content", systemPrompt } });
        object clientMessages;
        if (req.TryGetValue("messages", out clientMessages) && clientMessages is System.Collections.ArrayList)
        {
            foreach (var m in (System.Collections.ArrayList)clientMessages)
                if (m != null) messages.Add(m);
        }
        var payload = new Dictionary<string, object> { { "messages", messages } };
        // New gateway selects the model from the body; add it only when set.
        if (!string.IsNullOrEmpty(model)) payload["model"] = model;
        byte[] payloadBytes = Encoding.UTF8.GetBytes(ser.Serialize(payload));

        // New gateway is HTTPS with Windows integrated auth. Older .NET
        // Framework does not enable TLS 1.2 by default, which surfaces as
        // "The request was aborted: Could not create SSL/TLS secure channel".
        // Enable TLS 1.2 (and TLS 1.3 when the OS supports it) before the call.
        try { ServicePointManager.SecurityProtocol |= (SecurityProtocolType)3072; } catch { }   // TLS 1.2
        try { ServicePointManager.SecurityProtocol |= (SecurityProtocolType)12288; } catch { }  // TLS 1.3 (skip if unsupported)

        var hreq = (HttpWebRequest)WebRequest.Create(url);
        hreq.Method = "POST";
        hreq.Accept = "*/*";
        hreq.ContentType = "application/json";
        hreq.Headers["api-key"] = apiKey;
        if (!string.IsNullOrEmpty(userId)) hreq.Headers["user-id"] = userId;
        // New gateway uses Windows integrated auth (Negotiate/NTLM). Send the
        // server's own identity (the App Pool account) so the gateway does not
        // reply 401 and trigger a browser credential prompt.
        hreq.UseDefaultCredentials = true;
        hreq.PreAuthenticate = true;
        hreq.Timeout = 120000;
        hreq.ReadWriteTimeout = 120000;
        hreq.ContentLength = payloadBytes.Length;
        try
        {
            using (var s = hreq.GetRequestStream()) s.Write(payloadBytes, 0, payloadBytes.Length);
            using (var resp = (HttpWebResponse)hreq.GetResponse())
            using (var sr = new StreamReader(resp.GetResponseStream(), Encoding.UTF8))
                Response.Write(sr.ReadToEnd());
        }
        catch (WebException wex)
        {
            string detail = "";
            int status = 502;
            var http = wex.Response as HttpWebResponse;
            if (http != null)
            {
                status = (int)http.StatusCode;
                try
                {
                    using (var sr = new StreamReader(http.GetResponseStream(), Encoding.UTF8))
                        detail = sr.ReadToEnd();
                }
                catch { }
            }
            // Never pass a 401/407 straight back to the browser: if we do, IIS
            // appends a Negotiate challenge (WWW-Authenticate) to the outgoing
            // response and the browser pops a Windows login box. Remap those to
            // 502 so no challenge is added; the real status/error still travel
            // in the JSON error/detail fields below.
            Response.StatusCode = (status == 401 || status == 407) ? 502 : status;
            Response.Write("{\"ok\":false,\"error\":\"" + JsonEscape(wex.Message) + "\",\"detail\":" + ser.Serialize(detail) + "}");
        }
    }

    private static string JsonEscape(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }
}
