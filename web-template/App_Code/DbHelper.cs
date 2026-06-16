using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

// Lightweight parameterized SQL Server helper.
// Lives in App_Code so any page can call DbHelper.QueryRows(...) etc.
//
// Always uses @p0, @p1, ... positional parameters to defeat
// SQL injection.  Never string-concat user input into SQL.
public static class DbHelper
{
    private static string GetConnectionString()
    {
        var cs = ConfigurationManager.ConnectionStrings["DefaultDb"];
        if (cs == null)
            throw new Exception("connection string 'DefaultDb' missing from web.config");
        return cs.ConnectionString;
    }

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
                        if (v is DateTime) v = ((DateTime)v).ToString("o");
                        row[rdr.GetName(i)] = v;
                    }
                    rows.Add(row);
                }
            }
        }
        return rows;
    }

    public static Dictionary<string, object> QueryOne(string sql, params object[] args)
    {
        var rows = QueryRows(sql, args);
        return rows.Count > 0 ? rows[0] : null;
    }

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
}
