using System;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

public partial class GPTPoCDB_SampleSite_NotesTable : System.Web.UI.Page
{
    // ISO week helper (compatible with .NET 4.x)
    private static void GetIsoWeekYear(DateTime date, out int isoYear, out int isoWeek)
    {
        // ISO week: week starts Monday, week 1 is the week with Jan 4
        // Shift date to Thursday in the same week to determine ISO year
        int day = (int)date.DayOfWeek;
        if (day == 0) day = 7; // Sunday=7
        DateTime thursday = date.AddDays(4 - day);
        isoYear = thursday.Year;

        DateTime jan4 = new DateTime(isoYear, 1, 4);
        int jan4Day = (int)jan4.DayOfWeek;
        if (jan4Day == 0) jan4Day = 7;
        DateTime week1Start = jan4.AddDays(1 - jan4Day); // Monday of week 1

        isoWeek = (int)((thursday.Date - week1Start.Date).TotalDays / 7) + 1;
        if (isoWeek < 1) isoWeek = 1;
    }

    private static string ToShortToolLabel(string section, string tool)
    {
        if (string.IsNullOrEmpty(tool)) return tool;

        // section -> initial
        string initial = null;
        if (string.Equals(section, "NISACVD", StringComparison.OrdinalIgnoreCase)) initial = "N";
        else if (string.Equals(section, "SACVD", StringComparison.OrdinalIgnoreCase)) initial = "S";


        if (initial == null) return tool;

        string prefix = section + "-";
        if (tool.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
        {
            return initial + "-" + tool.Substring(prefix.Length);
        }

        return initial + "-" + tool;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string connStr = "Server=UMCESIDB02;Database=GPTPoCDB;User Id=GPTPoCDBUser;Password=DB02.2026;";

                // 依需求：只抓 NISACVD/SACVD
        string sql = @"
SELECT TOP (5000)
    [DataDate],
    [ISSUEDATE],
    [TITLE],
    [TECHNOLOGY],
    [PRODUCT],
    [LAYER],
    [DEFECTTYPE],
    [LOTID],
    [DEFECTDISTRIBUTION],
    [DEFECTIMAGE],
    [DEFECTMAP],
    [EDX],
    [EQPTYPE],
    [EQPID],
    [DOCURL]
FROM [GPTPoCDB].[dbo].[_DefectNotice_FAB]
WHERE
    (
        EQPID LIKE 'NISACVD-%' OR EQPID LIKE '%NISACVD%'
        OR EQPID LIKE 'SACVD-%' OR EQPID LIKE '%SACVD%'
    )
    AND ISSUEDATE >= @StartDate
    AND ISSUEDATE <  @EndDate
ORDER BY [DataDate] DESC;
";


                // Only show last 6 months window: now-6 months ~ now
                DateTime endDate = DateTime.Now;
                DateTime startDate = endDate.AddMonths(-6);


        using (SqlConnection conn = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@StartDate", startDate);
            cmd.Parameters.AddWithValue("@EndDate", endDate);


            conn.Open();
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                int ordDataDate = reader.GetOrdinal("DataDate");
                int ordIssueDate = reader.GetOrdinal("ISSUEDATE");
                int ordTitle = reader.GetOrdinal("TITLE");
                int ordTech = reader.GetOrdinal("TECHNOLOGY");
                int ordProduct = reader.GetOrdinal("PRODUCT");
                int ordLayer = reader.GetOrdinal("LAYER");
                int ordDefectType = reader.GetOrdinal("DEFECTTYPE");
                int ordLotId = reader.GetOrdinal("LOTID");
                int ordDefectDist = reader.GetOrdinal("DEFECTDISTRIBUTION");
                                int ordDefectImage = reader.GetOrdinal("DEFECTIMAGE");
                int ordDefectMap = reader.GetOrdinal("DEFECTMAP");
                int ordEdx = reader.GetOrdinal("EDX");
                int ordEqpType = reader.GetOrdinal("EQPTYPE");
                int ordEqpId = reader.GetOrdinal("EQPID");
                int ordDocUrl = reader.GetOrdinal("DOCURL");

                var sections = new[] { "NISACVD", "SACVD" };
                var sb = new StringBuilder();

                foreach (var section in sections)
                {
                    sb.Append("<div class='section'>")
                      .Append("<div class='section-title'>")
                      .Append(Server.HtmlEncode(section))
                      .Append("</div>");

                    // 對每一區都從頭掃一次 reader 不可能；所以先把資料一次讀到記憶體再分群。
                    // 這裡採用：第一次把資料讀完，存到 List，然後再輸出四區。
                    // 因為 TOP 1000，記憶體負擔很小。
                    break;
                }

                // 先把資料讀進來（.NET 4.0 不支援 Dictionary 的 index initializer： ["k"] = v，所以改用 Add）
                var rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, string>>();
                // NOTE: exclusions were ULKCVD-specific; cleared for NISACVD/SACVD
                var excludedEqp = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);

                while (reader.Read())
                {
                    string eqpid = reader.IsDBNull(ordEqpId) ? "" : reader.GetValue(ordEqpId).ToString();
                    string section = GetSectionFromEqpid(eqpid);
                    if (section == null) continue;

                    // filter out excluded EQP IDs (supports multi-token EQPID like A^B^C)
                    bool hitExcluded = false;
                    string[] tokens = eqpid.Split(new[] { '^' }, StringSplitOptions.RemoveEmptyEntries);
                    for (int ti = 0; ti < tokens.Length; ti++)
                    {
                        string t = (tokens[ti] ?? "").Trim();
                        if (t.Length == 0) continue;
                        if (excludedEqp.Contains(t)) { hitExcluded = true; break; }
                    }
                    if (hitExcluded) continue;

                    var d = new System.Collections.Generic.Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                    d.Add("Section", section);
                    d.Add("DataDate", reader.IsDBNull(ordDataDate) ? "" : reader.GetValue(ordDataDate).ToString());
                    d.Add("ISSUEDATE", reader.IsDBNull(ordIssueDate) ? "" : reader.GetValue(ordIssueDate).ToString());
                    d.Add("TITLE", reader.IsDBNull(ordTitle) ? "" : reader.GetValue(ordTitle).ToString());
                    d.Add("TECHNOLOGY", reader.IsDBNull(ordTech) ? "" : reader.GetValue(ordTech).ToString());
                    d.Add("PRODUCT", reader.IsDBNull(ordProduct) ? "" : reader.GetValue(ordProduct).ToString());
                    d.Add("LAYER", reader.IsDBNull(ordLayer) ? "" : reader.GetValue(ordLayer).ToString());
                    d.Add("DEFECTTYPE", reader.IsDBNull(ordDefectType) ? "" : reader.GetValue(ordDefectType).ToString());
                    d.Add("LOTID", reader.IsDBNull(ordLotId) ? "" : reader.GetValue(ordLotId).ToString());
                    d.Add("DEFECTDISTRIBUTION", reader.IsDBNull(ordDefectDist) ? "" : reader.GetValue(ordDefectDist).ToString());
                    d.Add("DEFECTIMAGE", reader.IsDBNull(ordDefectImage) ? "" : reader.GetValue(ordDefectImage).ToString());
                    d.Add("DEFECTMAP", reader.IsDBNull(ordDefectMap) ? "" : reader.GetValue(ordDefectMap).ToString());
                    d.Add("EDX", reader.IsDBNull(ordEdx) ? "" : reader.GetValue(ordEdx).ToString());
                    d.Add("EQPTYPE", reader.IsDBNull(ordEqpType) ? "" : reader.GetValue(ordEqpType).ToString());
                    d.Add("EQPID", eqpid);
                    d.Add("DOCURL", reader.IsDBNull(ordDocUrl) ? "" : reader.GetValue(ordDocUrl).ToString());

                    rows.Add(d);
                }

                // ===== Pivot table: X=Month (yyyy-MM), group by Defect pattern, Y=EQPID, value=count (ALL/P14/P56) =====
                var monthSet = new System.Collections.Generic.SortedSet<string>(StringComparer.Ordinal);
                var eqpSet = new System.Collections.Generic.SortedSet<string>(StringComparer.OrdinalIgnoreCase);

                // pivot[pattern][eqp][month] => int[3] { all, p14, p56 }
                var pivot = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int[]>>>(StringComparer.OrdinalIgnoreCase);

                foreach (var r in rows)
                {
                    DateTime dd;
                    if (!DateTime.TryParse(r["ISSUEDATE"] ?? "", out dd)) continue;
                    string monthKey = dd.ToString("yyyy-MM");
                    monthSet.Add(monthKey);

                    string eqpidRaw = r["EQPID"] ?? "";
                    string eqpid = NormalizeEqpid(r["Section"], eqpidRaw) ?? eqpidRaw;
                    if (string.IsNullOrWhiteSpace(eqpid)) continue;
                    eqpSet.Add(eqpid);

                    // group key = Defect pattern (DEFECTDISTRIBUTION)
                    string pattern = (r.ContainsKey("DEFECTDISTRIBUTION") ? (r["DEFECTDISTRIBUTION"] ?? "") : "").Trim();
                    if (pattern.Length == 0) pattern = "(blank)";

                    bool isP56 = eqpidRaw.IndexOf("-B", StringComparison.OrdinalIgnoreCase) >= 0;

                    System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int[]>> patternMap;
                    if (!pivot.TryGetValue(pattern, out patternMap))
                    {
                        patternMap = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int[]>>(StringComparer.OrdinalIgnoreCase);
                        pivot[pattern] = patternMap;
                    }

                    System.Collections.Generic.Dictionary<string, int[]> rowMap;
                    if (!patternMap.TryGetValue(eqpid, out rowMap))
                    {
                        rowMap = new System.Collections.Generic.Dictionary<string, int[]>(StringComparer.Ordinal);
                        patternMap[eqpid] = rowMap;
                    }

                    int[] arr;
                    if (!rowMap.TryGetValue(monthKey, out arr) || arr == null)
                    {
                        arr = new int[3];
                        rowMap[monthKey] = arr;
                    }

                    // all
                    arr[0] = arr[0] + 1;
                    if (isP56) arr[2] = arr[2] + 1; else arr[1] = arr[1] + 1;
                }

                var months = new System.Collections.Generic.List<string>();
                foreach (var m in monthSet) months.Add(m);

                var pivotSb = new StringBuilder();

                // ===== Pivot (not grouped): all patterns merged =====
                {
                    // eqp -> month -> int[3] { all, p14, p56 }
                    var pivotAll = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int[]>>(StringComparer.OrdinalIgnoreCase);

                    foreach (var r in rows)
                    {
                        DateTime dd;
                        if (!DateTime.TryParse(r["ISSUEDATE"] ?? "", out dd)) continue;
                        string monthKey = dd.ToString("yyyy-MM");

                        string eqpidRaw = r["EQPID"] ?? "";
                        string eqpid = NormalizeEqpid(r["Section"], eqpidRaw) ?? eqpidRaw;
                        if (string.IsNullOrWhiteSpace(eqpid)) continue;

                        bool isP56 = eqpidRaw.IndexOf("-B", StringComparison.OrdinalIgnoreCase) >= 0;

                        System.Collections.Generic.Dictionary<string, int[]> rowMap;
                        if (!pivotAll.TryGetValue(eqpid, out rowMap))
                        {
                            rowMap = new System.Collections.Generic.Dictionary<string, int[]>(StringComparer.Ordinal);
                            pivotAll[eqpid] = rowMap;
                        }

                        int[] arr;
                        if (!rowMap.TryGetValue(monthKey, out arr) || arr == null)
                        {
                            arr = new int[3];
                            rowMap[monthKey] = arr;
                        }

                        arr[0] = arr[0] + 1;
                        if (isP56) arr[2] = arr[2] + 1; else arr[1] = arr[1] + 1;
                    }

                    var eqpsAll = new System.Collections.Generic.List<string>(pivotAll.Keys);
                    eqpsAll.Sort(StringComparer.OrdinalIgnoreCase);

                    pivotSb.Append("<div class='section' data-section='PIVOTALL'>")
                           .Append("<div class='section-title'>Monthly x EQP ID (count)</div>")
                           .Append("<div class='dn-table-wrap'>")
                           .Append("<table class='dn-table pivotTable' id='pivotAllTable'>");

                    pivotSb.Append("<thead><tr>")
                           .Append("<th style='width:160px;'>EQP ID</th>");
                    for (int i = 0; i < months.Count; i++)
                    {
                        pivotSb.Append("<th class='num' style='width:90px;'>")
                               .Append(Server.HtmlEncode(months[i]))
                               .Append("</th>");
                    }
                    pivotSb.Append("<th class='num' style='width:100px;'>Total</th>")
                           .Append("</tr></thead>");

                    pivotSb.Append("<tbody>");

                    int grandAll = 0;
                    int grandP14 = 0;
                    int grandP56 = 0;
                    var monthTotalsAll = new int[months.Count];
                    var monthTotalsP14 = new int[months.Count];
                    var monthTotalsP56 = new int[months.Count];

                    for (int ei = 0; ei < eqpsAll.Count; ei++)
                    {
                        string eqp = eqpsAll[ei];
                        var rowMap = pivotAll[eqp];

                        pivotSb.Append("<tr data-pivot-row='1'>")
                               .Append("<td><a href='javascript:void(0)' class='pivot-eqp' data-eqp='")
                               .Append(Server.HtmlEncode(eqp))
                               .Append("'>")
                               .Append(Server.HtmlEncode(eqp))
                               .Append("</a></td>");

                        int rowAll = 0, rowP14 = 0, rowP56 = 0;
                        for (int i = 0; i < months.Count; i++)
                        {
                            int a = 0, p14 = 0, p56 = 0;
                            int[] arr;
                            if (rowMap != null && rowMap.TryGetValue(months[i], out arr) && arr != null)
                            {
                                a = arr[0];
                                p14 = arr[1];
                                p56 = arr[2];
                            }

                            rowAll += a; rowP14 += p14; rowP56 += p56;
                            monthTotalsAll[i] += a; monthTotalsP14[i] += p14; monthTotalsP56[i] += p56;

                            pivotSb.Append("<td class='num pivot-cell' data-month='")
                                   .Append(Server.HtmlEncode(months[i]))
                                   .Append("' data-all='")
                                   .Append(a)
                                   .Append("' data-p14='")
                                   .Append(p14)
                                   .Append("' data-p56='")
                                   .Append(p56)
                                   .Append("'>")
                                   .Append(a)
                                   .Append("</td>");
                        }

                        pivotSb.Append("<td class='num pivot-total' data-all='")
                               .Append(rowAll)
                               .Append("' data-p14='")
                               .Append(rowP14)
                               .Append("' data-p56='")
                               .Append(rowP56)
                               .Append("'>")
                               .Append(rowAll)
                               .Append("</td>")
                               .Append("</tr>");

                        grandAll += rowAll; grandP14 += rowP14; grandP56 += rowP56;
                    }

                    pivotSb.Append("<tr><th>Total</th>");
                    for (int i = 0; i < months.Count; i++)
                    {
                        pivotSb.Append("<th class='num pivot-col-total' data-month='")
                               .Append(Server.HtmlEncode(months[i]))
                               .Append("' data-all='")
                               .Append(monthTotalsAll[i])
                               .Append("' data-p14='")
                               .Append(monthTotalsP14[i])
                               .Append("' data-p56='")
                               .Append(monthTotalsP56[i])
                               .Append("'>")
                               .Append(monthTotalsAll[i])
                               .Append("</th>");
                    }
                    pivotSb.Append("<th class='num pivot-grand-total' data-all='")
                           .Append(grandAll)
                           .Append("' data-p14='")
                           .Append(grandP14)
                           .Append("' data-p56='")
                           .Append(grandP56)
                           .Append("'>")
                           .Append(grandAll)
                           .Append("</th></tr>")
                           .Append("</tbody></table></div></div>");
                }

                // ===== Pivot (grouped): one pivot table per Defect pattern =====
                pivotSb.Append("<div class='section' data-section='PIVOT'>")
                       .Append("<div class='section-title'>Monthly x EQP ID (count) - grouped by Defect pattern</div>");

                // Render one pivot table per Defect pattern
                var patternKeys = new System.Collections.Generic.List<string>(pivot.Keys);
                patternKeys.Sort(StringComparer.OrdinalIgnoreCase);

                for (int pk = 0; pk < patternKeys.Count; pk++)
                {
                    string pattern = patternKeys[pk];
                    System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int[]>> patternMap = pivot[pattern];

                    // table id unique per pattern (for JS filtering)
                    string tableId = "pivotTable_" + pk.ToString();

                    pivotSb.Append("<div class='section' data-section='PIVOTPAT'>")
                           .Append("<div class='section-title'>Defect pattern: ")
                           .Append(Server.HtmlEncode(pattern))
                           .Append("</div>")
                           .Append("<div class='dn-table-wrap'>")
                           .Append("<table class='dn-table pivotTable' id='")
                           .Append(tableId)
                           .Append("'>");

                    // header
                    pivotSb.Append("<thead><tr>")
                           .Append("<th style='width:160px;'>EQP ID</th>");
                    for (int i = 0; i < months.Count; i++)
                    {
                        pivotSb.Append("<th class='num' style='width:90px;'>")
                               .Append(Server.HtmlEncode(months[i]))
                               .Append("</th>");
                    }
                    pivotSb.Append("<th class='num' style='width:100px;'>Total</th>")
                           .Append("</tr></thead>");

                    pivotSb.Append("<tbody>");

                    int grandAll = 0;
                    int grandP14 = 0;
                    int grandP56 = 0;
                    var monthTotalsAll = new int[months.Count];
                    var monthTotalsP14 = new int[months.Count];
                    var monthTotalsP56 = new int[months.Count];

                    // Only render EQPs that exist in this pattern
                    var eqpsInPattern = new System.Collections.Generic.List<string>(patternMap.Keys);
                    eqpsInPattern.Sort(StringComparer.OrdinalIgnoreCase);

                    for (int ei = 0; ei < eqpsInPattern.Count; ei++)
                    {
                        string eqp = eqpsInPattern[ei];

                        pivotSb.Append("<tr data-pivot-row='1'>")
                               .Append("<td><a href='javascript:void(0)' class='pivot-eqp' data-eqp='")
                               .Append(Server.HtmlEncode(eqp))
                               .Append("'>")
                               .Append(Server.HtmlEncode(eqp))
                               .Append("</a></td>");

                        int rowAll = 0;
                        int rowP14 = 0;
                        int rowP56 = 0;

                        System.Collections.Generic.Dictionary<string, int[]> rowMap = patternMap[eqp];

                        for (int i = 0; i < months.Count; i++)
                        {
                            int a = 0, p14 = 0, p56 = 0;
                            if (rowMap != null)
                            {
                                int[] arr;
                                if (rowMap.TryGetValue(months[i], out arr) && arr != null)
                                {
                                    a = arr[0];
                                    p14 = arr[1];
                                    p56 = arr[2];
                                }
                            }

                            rowAll += a;
                            rowP14 += p14;
                            rowP56 += p56;
                            monthTotalsAll[i] += a;
                            monthTotalsP14[i] += p14;
                            monthTotalsP56[i] += p56;

                            pivotSb.Append("<td class='num pivot-cell' data-month='")
                                   .Append(Server.HtmlEncode(months[i]))
                                   .Append("' data-all='")
                                   .Append(a)
                                   .Append("' data-p14='")
                                   .Append(p14)
                                   .Append("' data-p56='")
                                   .Append(p56)
                                   .Append("'>")
                                   .Append(a)
                                   .Append("</td>");
                        }

                        pivotSb.Append("<td class='num pivot-total' data-all='")
                               .Append(rowAll)
                               .Append("' data-p14='")
                               .Append(rowP14)
                               .Append("' data-p56='")
                               .Append(rowP56)
                               .Append("'>")
                               .Append(rowAll)
                               .Append("</td>")
                               .Append("</tr>");

                        grandAll += rowAll;
                        grandP14 += rowP14;
                        grandP56 += rowP56;
                    }

                    // footer total row
                    pivotSb.Append("<tr>")
                           .Append("<th>Total</th>");
                    for (int i = 0; i < months.Count; i++)
                    {
                        pivotSb.Append("<th class='num pivot-col-total' data-month='")
                               .Append(Server.HtmlEncode(months[i]))
                               .Append("' data-all='")
                               .Append(monthTotalsAll[i])
                               .Append("' data-p14='")
                               .Append(monthTotalsP14[i])
                               .Append("' data-p56='")
                               .Append(monthTotalsP56[i])
                               .Append("'>")
                               .Append(monthTotalsAll[i])
                               .Append("</th>");
                    }
                    pivotSb.Append("<th class='num pivot-grand-total' data-all='")
                           .Append(grandAll)
                           .Append("' data-p14='")
                           .Append(grandP14)
                           .Append("' data-p56='")
                           .Append(grandP56)
                           .Append("'>")
                           .Append(grandAll)
                           .Append("</th>")
                           .Append("</tr>");

                    pivotSb.Append("</tbody></table></div></div>");
                }

                pivotSb.Append("</div>");

                phTable.Controls.Add(new Literal { Text = pivotSb.ToString() });

                // ===== Trend data: count by DataDate (yyyy-MM-dd), per section =====
                DateTime minDate = DateTime.MaxValue;
                DateTime maxDate = DateTime.MinValue;

                var trendAll = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int>>(StringComparer.Ordinal);
                var trendP14 = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int>>(StringComparer.Ordinal);
                var trendP56 = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int>>(StringComparer.Ordinal);

                foreach (var sec0 in new[] { "NISACVD", "SACVD" })
                {
                    trendAll.Add(sec0, new System.Collections.Generic.Dictionary<string, int>(StringComparer.Ordinal));
                    trendP14.Add(sec0, new System.Collections.Generic.Dictionary<string, int>(StringComparer.Ordinal));
                    trendP56.Add(sec0, new System.Collections.Generic.Dictionary<string, int>(StringComparer.Ordinal));
                }

                foreach (var r in rows)
                {
                    var sec = r["Section"];
                    var dd = r["DataDate"] ?? "";
                    var rawEqpid = r["EQPID"] ?? "";
                    bool isP56 = rawEqpid.IndexOf("-B", StringComparison.OrdinalIgnoreCase) >= 0;

                    DateTime parsed;
                    if (!DateTime.TryParse(dd, out parsed)) continue;

                    // 只保留日期
                    parsed = parsed.Date;
                    if (parsed < minDate) minDate = parsed;
                    if (parsed > maxDate) maxDate = parsed;

                    string key = parsed.ToString("yyyy-MM-dd");

                    // ALL
                    int v;
                    if (!trendAll[sec].TryGetValue(key, out v)) v = 0;
                    trendAll[sec][key] = v + 1;

                    // P14/P56
                    if (isP56)
                    {
                        int v56;
                        if (!trendP56[sec].TryGetValue(key, out v56)) v56 = 0;
                        trendP56[sec][key] = v56 + 1;
                    }
                    else
                    {
                        int v14;
                        if (!trendP14[sec].TryGetValue(key, out v14)) v14 = 0;
                        trendP14[sec][key] = v14 + 1;
                    }
                }

                // 產生完整日期軸：沒有的日期也補 0
                var labels = new System.Collections.Generic.List<string>();
                if (minDate != DateTime.MaxValue && maxDate != DateTime.MinValue)
                {
                    for (var d = minDate; d <= maxDate; d = d.AddDays(1))
                    {
                        labels.Add(d.ToString("yyyy-MM-dd"));
                    }
                }

                // ===== Weekly table: count by week (Mon-Sun), per section =====
                var weeklyCounts = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int>>(StringComparer.Ordinal);
                weeklyCounts.Add("NISACVD", new System.Collections.Generic.Dictionary<string, int>(StringComparer.Ordinal));
                weeklyCounts.Add("SACVD", new System.Collections.Generic.Dictionary<string, int>(StringComparer.Ordinal));

                foreach (var r in rows)
                {
                    var sec = r["Section"];
                    var dd = r["DataDate"] ?? "";
                    DateTime parsed;
                    if (!DateTime.TryParse(dd, out parsed)) continue;
                    parsed = parsed.Date;

                    // Week start = Monday
                    int dow = (int)parsed.DayOfWeek; // Sun=0
                    int offset = dow == 0 ? -6 : (1 - dow);
                    var weekStart = parsed.AddDays(offset);
                    string wk = weekStart.ToString("yyyy-MM-dd");

                    int v;
                    if (!weeklyCounts[sec].TryGetValue(wk, out v)) v = 0;
                    weeklyCounts[sec][wk] = v + 1;
                }

                var weekLabels = new System.Collections.Generic.SortedSet<string>(StringComparer.Ordinal);
                foreach (var sec in new[] { "NISACVD", "SACVD" })
                {
                    foreach (var kv in weeklyCounts[sec]) weekLabels.Add(kv.Key);
                }

                // 輸出到 JS（window.__trendData）：提供 ALL/P14/P56 三套 series
                // 同時輸出：
                // - performance raw rows（window.__perfRows）
                // - EQ chart raw rows（window.__eqChartRows）：供前端做「X=EQPID(機台)、legend=Week」圖表
                var js = new StringBuilder();
                js.Append("<script>");

                // perf rows
                js.Append("window.__perfRows=[");
                bool firstPerf = true;
                for (int i = 0; i < rows.Count; i++)
                {
                    var r = rows[i];
                    string sec = r["Section"] ?? "";
                    string dd = r["DataDate"] ?? "";
                    string eqpidRaw = r["EQPID"] ?? "";

                    DateTime parsed;
                    if (!DateTime.TryParse(dd, out parsed)) continue;
                    string d = parsed.Date.ToString("yyyy-MM-dd");

                    string tool = NormalizeEqpid(sec, eqpidRaw) ?? "";
                    bool isP56 = eqpidRaw.IndexOf("-B", StringComparison.OrdinalIgnoreCase) >= 0;

                    if (!firstPerf) js.Append(",");
                    firstPerf = false;

                    js.Append("{d:\"")
                      .Append(d)
                      .Append("\",sec:\"")
                      .Append(sec.Replace("\\", "\\\\").Replace("\"", "\\\""))
                      .Append("\",tool:\"")
                      .Append(tool.Replace("\\", "\\\\").Replace("\"", "\\\""))
                      .Append("\",isP56:")
                      .Append(isP56 ? "1" : "0")
                      .Append("}");
                }
                js.Append("];\n");

                // eq chart rows: one event per row, front-end will group by week + tool
                js.Append("window.__eqChartRows=[");
                bool firstEq = true;
                for (int i = 0; i < rows.Count; i++)
                {
                    var r = rows[i];
                    string sec = r["Section"] ?? "";
                    string dd = r["DataDate"] ?? "";
                    string eqpidRaw = r["EQPID"] ?? "";

                    DateTime parsed;
                    if (!DateTime.TryParse(dd, out parsed)) continue;

                    // Week start = Monday
                    int dow = (int)parsed.DayOfWeek; // Sun=0
                    int offset = dow == 0 ? -6 : (1 - dow);
                    DateTime weekStart = parsed.Date.AddDays(offset);
                    int isoYear, isoWeek;
                    GetIsoWeekYear(weekStart, out isoYear, out isoWeek);
                    string wk = isoYear.ToString() + "W" + isoWeek.ToString("D02");

                    string tool = NormalizeEqpid(sec, eqpidRaw) ?? "";
                    bool isP56 = eqpidRaw.IndexOf("-B", StringComparison.OrdinalIgnoreCase) >= 0;

                    if (!firstEq) js.Append(",");
                    firstEq = false;

                    // short label: NISACVD-01 => N-01, SACVD-01 => S-01
                    string shortTool = ToShortToolLabel(sec, tool);

                    js.Append("{wk:\"")
                      .Append(wk)
                      .Append("\",sec:\"")
                      .Append(sec.Replace("\\", "\\\\").Replace("\"", "\\\""))
                      .Append("\",tool:\"")
                      .Append(tool.Replace("\\", "\\\\").Replace("\"", "\\\""))
                      .Append("\",toolShort:\"")
                      .Append(shortTool.Replace("\\", "\\\\").Replace("\"", "\\\""))
                      .Append("\",isP56:")
                      .Append(isP56 ? "1" : "0")
                      .Append("}");
                }
                js.Append("];\n");

                js.Append("window.__trendData={labels:[");
                for (int i = 0; i < labels.Count; i++)
                {
                    if (i > 0) js.Append(",");
                    js.Append("\"").Append(labels[i].Replace("\"", "\\\"")).Append("\"");
                }

                js.Append("],seriesAll:{");
                AppendTrendSeries(js, labels, trendAll);
                js.Append("},seriesP14:{");
                AppendTrendSeries(js, labels, trendP14);
                js.Append("},seriesP56:{");
                AppendTrendSeries(js, labels, trendP56);
                js.Append("}};</script>");

                // 先把 JS script 丟到最前面，確保前端圖表可讀到資料
                phTable.Controls.Add(new Literal { Text = js.ToString() });

                

                                // ===== 近 1 週重複 EQPID 偵測（以 token 為單位） =====
                var recentEqpidCount = new System.Collections.Generic.Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
                                foreach (var r in rows)
                {
                    DateTime dd;
                    // Use ISSUEDATE for rolling window (same as SQL filter)
                    if (!DateTime.TryParse(r["ISSUEDATE"] ?? "", out dd)) continue;
                    if (dd < DateTime.Now.AddDays(-7)) continue;


                    string eqpidRaw = r["EQPID"] ?? "";
                    char[] seps = new[] { '^' };
                    string[] parts = eqpidRaw.Split(seps, StringSplitOptions.RemoveEmptyEntries);
                    for (int i = 0; i < parts.Length; i++)
                    {
                        string p = parts[i].Trim();
                        if (p.Length == 0) continue;
                        int c;
                        if (!recentEqpidCount.TryGetValue(p, out c)) c = 0;
                        recentEqpidCount[p] = c + 1;
                    }
                }

                                // 24hr notice removed
                                // ===== 輸出四區（table mode，像你提供的截圖：上方 header + filter row + 列表） =====
                sb.Clear();

                // 基本欄位對應：我們先用現有 DB 欄位來拼出類似截圖的表
                // 欄位：Title / Product / Technology(當 Customer) / Layer / DefectType / EQPID / DEFECTDISTRIBUTION(當 Root cause/Distribution) / EDX(當 Pattern)
                // 圖片欄位：目前 DB 沒有 defect image / defect map 的 URL，先放 placeholder（之後可改成實際 URL 欄位）

                foreach (var section in sections)
                {
                    int count = 0;
                    foreach (var row in rows)
                    {
                        if (string.Equals(row["Section"], section, StringComparison.Ordinal)) count++;
                    }

                    sb.Append("<div class='section' data-section='")
                      .Append(Server.HtmlEncode(section))
                      .Append("'>");

                    sb.Append("<div class='section-title has-search'>")
                      .Append("<div>")
                      .Append(Server.HtmlEncode(section))
                      .Append(" <span class='section-count'>")
                      .Append(Server.HtmlEncode("(n=" + count + ")"))
                      .Append("</span></div>");

                    // 只有第一個區塊放 input（避免 id 重複）；但它會共用過濾所有區塊
                    if (string.Equals(section, "NISACVD", StringComparison.Ordinal))
                    {
                        sb.Append("<div class='title-right'>")
                          .Append("<span class='search-label'>Search</span>")
                          .Append("<span class='search-label'>LOTID</span><input id='qLot' type='text' placeholder='contains...' />")
                          .Append("<span class='search-label'>EQPID</span><input id='qEqp' type='text' placeholder='contains...' />")
                          .Append("</div>");
                    }

                    sb.Append("</div>");

                    sb.Append("<div class='dn-table-wrap'>");
                                        sb.Append("<table class='dn-table' data-section-table='")
                      .Append(Server.HtmlEncode(section))
                      .Append("'>");

                    // fixed column widths (consistent across all sections)
                    sb.Append("<colgroup>")
                      .Append("<col style='width:420px;' />") // Title
                      .Append("<col style='width:90px;' />")  // Product
                      .Append("<col style='width:90px;' />")  // Layer
                      .Append("<col style='width:120px;' />") // Defect Type
                      .Append("<col style='width:160px;' />") // EQP ID
                      .Append("<col style='width:120px;' />") // Defect pattern
                      .Append("<col style='width:90px;' />")  // Defect image
                      .Append("<col style='width:90px;' />")  // Defect map
                      .Append("</colgroup>");

                    // header
                    sb.Append("<thead>");
                    sb.Append("<tr>")
                      .Append("<th>Title</th>")
                      .Append("<th>Product</th>")
                      .Append("<th>Layer</th>")
                      .Append("<th>Defect Type</th>")
                      .Append("<th>EQP ID</th>")
                      .Append("<th>Defect pattern</th>")
                      .Append("<th>Defect image</th>")
                      .Append("<th>Defect map</th>")
                      .Append("</tr>");


                    
                    sb.Append("</thead>");

                    sb.Append("<tbody>");

                    foreach (var row in rows)
                    {
                        if (!string.Equals(row["Section"], section, StringComparison.Ordinal)) continue;

                        // 讓前端 filter 可用（沿用既有 data-*）
                        string rawEqpid = row["EQPID"] ?? "";
                        string normEqpid = NormalizeEqpid(section, rawEqpid);
                        bool isP56 = rawEqpid.IndexOf("-B", StringComparison.OrdinalIgnoreCase) >= 0;

                        // title link to doc
                        string docUrl = row["DOCURL"] ?? "";
                        string titleText = row["TITLE"] ?? "";
                        string titleHtml;
                        if (!string.IsNullOrWhiteSpace(docUrl))
                        {
                            string url = Server.HtmlEncode(docUrl);
                            titleHtml = "<a href='" + url + "' target='_blank' rel='noopener noreferrer'>" + Server.HtmlEncode(titleText) + "</a>";
                        }
                        else
                        {
                            titleHtml = Server.HtmlEncode(titleText);
                        }

                        // EQPID multi-line display: only keep NISACVD-/SACVD- tokens
                        string[] eqParts = (row["EQPID"] ?? "").Split(new[] { '^' }, StringSplitOptions.RemoveEmptyEntries);
                        var eqSb = new StringBuilder();
                        for (int i = 0; i < eqParts.Length; i++)
                        {
                            string p = eqParts[i].Trim();
                            if (p.Length == 0) continue;
                            if (!p.StartsWith("NISACVD-", StringComparison.OrdinalIgnoreCase)
                                && !p.StartsWith("SACVD-", StringComparison.OrdinalIgnoreCase)) continue;
                            if (eqSb.Length > 0) eqSb.Append("\n");

                            int c;
                            bool dup = recentEqpidCount.TryGetValue(p, out c) && c >= 2;
                            if (dup)
                            {
                                eqSb.Append(p).Append(" (dup)");
                            }
                            else
                            {
                                eqSb.Append(p);
                            }
                        }

                        string dataDate = row["DataDate"] ?? "";

                                                string defectImage = row.ContainsKey("DEFECTIMAGE") ? (row["DEFECTIMAGE"] ?? "") : "";
                                                string defectMap = row.ContainsKey("DEFECTMAP") ? (row["DEFECTMAP"] ?? "") : "";

                                                // DB may store relative path or wrong host; normalize to an absolute URL
                                                // Expected base: http://P58ESIGP01/DefectMapImage/Fab/2026/
                                                defectImage = NormalizeMediaUrl(defectImage, "http://P58ESIGP01/DefectMapImage/Fab/2026/");
                                                defectMap = NormalizeMediaUrl(defectMap, "http://P58ESIGP01/DefectMapImage/Fab/2026/");




                        // fallback placeholder SVG data URI
                        string imgSvg = "data:image/svg+xml;utf8," +
                                        "<svg xmlns='http://www.w3.org/2000/svg' width='88' height='120'>" +
                                        "<rect width='100%25' height='100%25' fill='rgb(30,41,59)'/>" +
                                        "<text x='50%25' y='50%25' dominant-baseline='middle' text-anchor='middle' fill='rgb(148,163,184)' font-size='14'>N/A</text>" +
                                        "</svg>";

                                                // IMPORTANT: do not HTML-encode URLs inside src; it breaks querystring (& => &amp;)
                        string imgSrc = string.IsNullOrWhiteSpace(defectImage) ? imgSvg : defectImage;
                        string mapSrc = string.IsNullOrWhiteSpace(defectMap) ? imgSvg : defectMap;



                        sb.Append("<tr class='dn-row item' data-parent-section='")
                          .Append(Server.HtmlEncode(section))
                          .Append("' data-sub-eqpid='")
                          .Append(Server.HtmlEncode(normEqpid))
                          .Append("' data-is-p56='")
                          .Append(isP56 ? "1" : "0")
                          .Append("' data-lotid='")
                          .Append(Server.HtmlEncode(row["LOTID"] ?? ""))
                          .Append("' data-eqpid='")
                          .Append(Server.HtmlEncode(row["EQPID"] ?? ""))
                          .Append("'>");

                        sb.Append("<td class='dn-title-cell'>")
                          .Append(titleHtml)
                          .Append("<div class='dn-dd'>")
                          .Append(Server.HtmlEncode(dataDate))
                          .Append("</div></td>");

                                                sb.Append("<td>").Append(Server.HtmlEncode(row["PRODUCT"] ?? "")).Append("</td>");
                        sb.Append("<td>").Append(Server.HtmlEncode(row["LAYER"] ?? "")).Append("</td>");
                        sb.Append("<td>").Append(Server.HtmlEncode(row["DEFECTTYPE"] ?? "")).Append("</td>");
                        sb.Append("<td class='dn-eqpid-cell'>").Append(Server.HtmlEncode(eqSb.ToString())).Append("</td>");

                        // Defect pattern = DEFECTDISTRIBUTION
                        sb.Append("<td>").Append(Server.HtmlEncode(row["DEFECTDISTRIBUTION"] ?? "")).Append("</td>");

                                                sb.Append("<td><a href='")
                          .Append(Server.HtmlEncode(imgSrc))
                          .Append("' target='_blank' rel='noopener noreferrer'><img class='dn-img' alt='defect image' src='")
                          .Append(Server.HtmlEncode(imgSrc))
                          .Append("'/></a></td>");
                        sb.Append("<td><a href='")
                          .Append(Server.HtmlEncode(mapSrc))
                          .Append("' target='_blank' rel='noopener noreferrer'><img class='dn-img dn-map' alt='defect map' src='")
                          .Append(Server.HtmlEncode(mapSrc))
                          .Append("'/></a></td>");



                        sb.Append("</tr>");
                    }

                    sb.Append("</tbody></table></div>");
                    sb.Append("</div>");
                }

                phTable.Controls.Add(new Literal { Text = sb.ToString() });

            }
        }
    }

    private static string GetSectionFromEqpid(string eqpid)
    {
        if (string.IsNullOrWhiteSpace(eqpid)) return null;

        // EQPID 可能是多台串起來（例如 CUSILPE-B21^ALDOX-E04^^^^）
        // 只要任一段符合指定前綴，就歸到該 Section。
        string[] parts = eqpid.Split(new[] { '^' }, StringSplitOptions.RemoveEmptyEntries);
        for (int i = 0; i < parts.Length; i++)
        {
            string p = parts[i].Trim();
            if (p.Length == 0) continue;

            if (p.StartsWith("NISACVD-", StringComparison.OrdinalIgnoreCase)) return "NISACVD";
            if (p.StartsWith("SACVD-", StringComparison.OrdinalIgnoreCase)) return "SACVD";

        }

        // 如果沒有 ^，或 Split 後沒有命中，退回用 contains 判斷（避免漏資料）
        if (eqpid.IndexOf("NISACVD-", StringComparison.OrdinalIgnoreCase) >= 0) return "NISACVD";
        if (eqpid.IndexOf("SACVD-", StringComparison.OrdinalIgnoreCase) >= 0) return "SACVD";

        return null;
    }

    // 分類精簡：例如 ALDOX 區內，只取出 ALDOX-04 (遇到 ALDOX-04^ALDOX-A15... 也歸到 ALDOX-04)
    private static string NormalizeEqpid(string section, string eqpidRaw)
    {
        if (string.IsNullOrEmpty(eqpidRaw)) return eqpidRaw;

        // 先切開（你的資料看起來會用 ^ 或 , 等把多台串一起）
        char[] seps = new[] { '^', ',', ';', ' ', '\t', '|', '/', '\\' };
        string[] parts = eqpidRaw.Split(seps, StringSplitOptions.RemoveEmptyEntries);

        string prefix = section + "-";
        string candidate = null;
        for (int i = 0; i < parts.Length; i++)
        {
            string p = parts[i].Trim();
            if (p.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
            {
                candidate = p;
                break;
            }
        }
        if (candidate == null) candidate = eqpidRaw.Trim();

        // 取 '-' 後的連續數字（ALDOX-04A => 04；ALDOX-004 => 004）
        int dash = candidate.IndexOf('-');
        if (dash < 0) return candidate;
        string rest = candidate.Substring(dash + 1);

        var num = new StringBuilder();
        for (int i = 0; i < rest.Length; i++)
        {
            char c = rest[i];
            if (char.IsDigit(c)) num.Append(c);
            else break;
        }

        if (num.Length > 0)
        {
            return section + "-" + num.ToString();
        }

        // 沒數字就退而求其次：取到下一個分隔，避免整串很長
        string token = rest;
        int cut = token.IndexOfAny(new[] { '-', '^', ',', ';', ' ' });
        if (cut > 0) token = token.Substring(0, cut);
        return section + "-" + token;
    }

        private static string NormalizeMediaUrl(string raw, string baseUrl)
    {
                raw = (raw ?? "").Trim();
        if (raw.Length == 0) return "";

        // If multiple files are concatenated (e.g. A_1.jpeg^A_2.jpeg), take the first one
        int caret = raw.IndexOf('^');
        if (caret > 0) raw = raw.Substring(0, caret).Trim();


                // If already absolute
        if (raw.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || raw.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            return raw;
        }

        // Convert windows path separators
        raw = raw.Replace("\\", "/");

        // If DB stores a full path-like string (e.g. umcesidb02/PoC/.../xxx.jpg), keep only file name
        int lastSlash = raw.LastIndexOf('/');
        if (lastSlash >= 0 && lastSlash < raw.Length - 1)
        {
            raw = raw.Substring(lastSlash + 1);
        }

        // Remove leading slash to safely combine
        while (raw.StartsWith("/")) raw = raw.Substring(1);

        // Ensure baseUrl ends with '/'
        if (!baseUrl.EndsWith("/")) baseUrl += "/";

        return baseUrl + raw;

    }

    private static void AppendTrendSeries(

        StringBuilder js,
        System.Collections.Generic.List<string> labels,
        System.Collections.Generic.Dictionary<string, System.Collections.Generic.Dictionary<string, int>> series)
      {
                        foreach (var sec in new[] { "NISACVD", "SACVD" })
                {
            js.Append(sec).Append(":[");
            for (int i = 0; i < labels.Count; i++)
            {
                if (i > 0) js.Append(",");
                int v;
                if (!series[sec].TryGetValue(labels[i], out v)) v = 0;
                js.Append(v);
            }
            js.Append("],");
        }
    }

    private static string FormatEqpidDisplay(string eqpidRaw, string section)
    {
        if (string.IsNullOrWhiteSpace(eqpidRaw)) return "";

        // 以 ^ 分隔（同時兼容其他分隔）
        char[] seps = new[] { '^', ',', ';', '|' };
        string[] parts = eqpidRaw.Split(seps, StringSplitOptions.RemoveEmptyEntries);

        var list = new System.Collections.Generic.List<string>();
        for (int i = 0; i < parts.Length; i++)
        {
            string p = parts[i].Trim();
            if (p.Length == 0) continue;
            list.Add(p);
        }

        // 排序：同 section prefix 的放前面，其餘後面；各自再字母序
        string prefix = section + "-";
        list.Sort((a, b) =>
        {
            bool aIn = a.StartsWith(prefix, StringComparison.OrdinalIgnoreCase);
            bool bIn = b.StartsWith(prefix, StringComparison.OrdinalIgnoreCase);
            if (aIn != bIn) return aIn ? -1 : 1;
            return string.Compare(a, b, StringComparison.OrdinalIgnoreCase);
        });

        // HTML：每個 token 一行（要 encode）
        var sb = new StringBuilder();
        for (int i = 0; i < list.Count; i++)
        {
            if (i > 0) sb.Append("<br/>");
            sb.Append(System.Web.HttpUtility.HtmlEncode(list[i]));
        }
        return sb.ToString();
    }

    private static string ShortTitle(string title)
    {
        if (string.IsNullOrWhiteSpace(title)) return "";
        title = title.Trim();

        // 先在第一個 '/' 之前截斷，例如 "[L22] GMS4M / ACH7A.0" -> "[L22] GMS4M"
        int slash = title.IndexOf('/');
        if (slash > 0) title = title.Substring(0, slash).Trim();

        // 再只保留前兩個 token（以空白分隔），例如 "[L22] GMS4M"
        string[] parts = title.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length >= 2) return parts[0] + " " + parts[1];
        return title;
    }

    private string Kv(string k, string v)
    {
        return "<div class='kv-row'><div class='k'>" + Server.HtmlEncode(k) + "</div><div class='v'>" + Server.HtmlEncode(v ?? "") + "</div></div>";
    }
}
