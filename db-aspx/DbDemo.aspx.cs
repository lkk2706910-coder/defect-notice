using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

// Standalone DB-access template (SQL Server / System.Data.SqlClient).
//
// Drop this folder into any IIS site, set the DefaultDb connection
// string in web.config, and you have a working
//   GET DbDemo.aspx?op=rows&q=getTables   -> JSON
// endpoint plus a demo HTML page that renders it.
//
// To use this from your own page:
//   var rows = DbHelper.QueryRows("SELECT a, b FROM t WHERE c = @p0", 42);
//   var one  = DbHelper.QueryOne("SELECT COUNT(*) AS n FROM t");
//   var n    = DbHelper.Execute("UPDATE t SET x = @p0 WHERE id = @p1", "new", 7);
//
// Add named SQL strings to NamedQueries below, then the JSON endpoint
// at ?op=rows&q=NAME serves them. Never let untrusted clients pass
// raw SQL: only allow names from this whitelist.
public partial class DbDemo : Page
{
    // Whitelisted queries the JSON endpoint will run. Add your own here.
    private static readonly Dictionary<string, string> NamedQueries =
        new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
    {
        // Default safe demo: list a few system table names. Works on any
        // SQL Server DB without needing custom schema.
        { "getTables", "SELECT TOP 20 name, create_date FROM sys.tables ORDER BY name" },

        // Example with one parameter: GET ?op=rows&q=findTablesLike&p0=user
        // Returns table names containing the substring.
        { "findTablesLike", "SELECT TOP 50 name, create_date FROM sys.tables WHERE name LIKE '%' + @p0 + '%' ORDER BY name" },
    };

    protected void Page_Load(object sender, EventArgs e)
    {
        string op = Request.QueryString["op"];
        if (string.IsNullOrEmpty(op)) return; // fall through to the demo HTML

        Response.ContentType = "application/json; charset=utf-8";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        try
        {
            if (string.Equals(op, "rows", StringComparison.OrdinalIgnoreCase))
            {
                HandleRows();
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
            Response.Write("{\"ok\":false,\"error\":" + DbHelper.JsonString(ex.Message) + "}");
        }
        Response.End();
    }

    private void HandleRows()
    {
        string name = Request.QueryString["q"];
        if (string.IsNullOrEmpty(name) || !NamedQueries.ContainsKey(name))
        {
            Response.StatusCode = 400;
            Response.Write("{\"ok\":false,\"error\":\"unknown query name\"}");
            return;
        }
        // Optional positional parameters: p0, p1, ... passed in query string.
        var args = new List<object>();
        for (int i = 0; ; i++)
        {
            string v = Request.QueryString["p" + i];
            if (v == null) break;
            args.Add(v);
        }
        var rows = DbHelper.QueryRows(NamedQueries[name], args.ToArray());
        Response.Write("{\"ok\":true,\"rows\":" + DbHelper.ToJson(rows) + "}");
    }
}

// ===========================================================
// DbHelper - reusable static class for parameterized DB access.
// Put this in App_Code if you want to share across multiple
// pages, or keep it in this file for a single drop-in page.
// ===========================================================
public static class DbHelper
{
    private static string GetConnectionString()
    {
        var cs = ConfigurationManager.ConnectionStrings["DefaultDb"];
        if (cs == null)
            throw new Exception("connection string 'DefaultDb' missing from web.config");
        return cs.ConnectionString;
    }

    // Run a SELECT and return rows as a list of column-name -> value maps.
    // SQL uses positional parameters @p0, @p1, ... matched to args[] order.
    public static List<Dictionary<string, object>> QueryRows(string sql, params object[] args)
    {
        var rows = new List<Dictionary<string, object>>();
        using (var conn = new SqlConnection(GetConnectionString()))
        using (var cmd = new SqlCommand(sql, conn))
        {
            BindArgs(cmd, args);
            conn.Open();
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var row = new Dictionary<string, object>(rdr.FieldCount);
                    for (int i = 0; i < rdr.FieldCount; i++)
                    {
                        object v = rdr.IsDBNull(i) ? null : rdr.GetValue(i);
                        // DateTime -> ISO 8601 string so JSON parses cleanly on JS side.
                        if (v is DateTime) v = ((DateTime)v).ToString("o");
                        row[rdr.GetName(i)] = v;
                    }
                    rows.Add(row);
                }
            }
        }
        return rows;
    }

    // Single-row shortcut. Returns null if no rows matched.
    public static Dictionary<string, object> QueryOne(string sql, params object[] args)
    {
        var rows = QueryRows(sql, args);
        return rows.Count > 0 ? rows[0] : null;
    }

    // Scalar shortcut, e.g. COUNT(*).
    public static object QueryScalar(string sql, params object[] args)
    {
        using (var conn = new SqlConnection(GetConnectionString()))
        using (var cmd = new SqlCommand(sql, conn))
        {
            BindArgs(cmd, args);
            conn.Open();
            object o = cmd.ExecuteScalar();
            return o == DBNull.Value ? null : o;
        }
    }

    // INSERT / UPDATE / DELETE. Returns rows-affected.
    public static int Execute(string sql, params object[] args)
    {
        using (var conn = new SqlConnection(GetConnectionString()))
        using (var cmd = new SqlCommand(sql, conn))
        {
            BindArgs(cmd, args);
            conn.Open();
            return cmd.ExecuteNonQuery();
        }
    }

    private static void BindArgs(SqlCommand cmd, object[] args)
    {
        if (args == null) return;
        for (int i = 0; i < args.Length; i++)
        {
            cmd.Parameters.AddWithValue("@p" + i, args[i] ?? (object)DBNull.Value);
        }
    }

    public static string ToJson(object data)
    {
        var ser = new JavaScriptSerializer { MaxJsonLength = 100 * 1024 * 1024 };
        return ser.Serialize(data);
    }

    public static string JsonString(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "") + "\"";
    }
}
