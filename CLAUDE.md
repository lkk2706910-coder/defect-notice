# defect-notice

## 用途
Defect Notice 資料庫瀏覽器（NISACVD / SACVD 機台），讀 GPTPoCDB 的 `_DefectNotice_FAB` 表，顯示近 6 個月缺陷通知與圖片。

## 主要檔案
- `Defectnotice.aspx` / `.cs` — v1（基本表格）
- `Defectnotice2.aspx` / `.cs` — v2（直向卡片式）
- `Defectnotice4.aspx` / `.cs` — v4（v2 + 新增欄位）
- `README.md` — 只有標題

## 對外可複用功能
- `GetIsoWeekYear(DateTime date, out int isoYear, out int isoWeek)` — .NET 4.x 相容的 ISO 週計算（不依賴 `System.Globalization.ISOWeek`）
- `ToShortToolLabel(section, tool)` — `NISACVD-xxx → N-xxx`、`SACVD-xxx → S-xxx`
- 6 個月時間窗 + `EQPID LIKE` 篩選的 SQL 範本

## 依賴
.NET Framework 4.x / IIS / SqlClient

## 開發備註
- SQL 連線字串放在 `connections.config`（gitignored）。範例見 `connections.config.sample`
- 三版同時存在（v1 / v2 / v4），可能其中一兩個是廢棄版本 — 需 Allen 確認
- 目前 HEAD 在 `claude/html-table-add-column-n26obt` branch（無 local main）
- 多個 branch：`claude/ai-db-template`、`claude/defect-case-lesson-learn`（含 AI function 版）、`claude/merge-all` / `claude/merge-all-v2`、`claude/new-fab-sample`、`claude/original-version`、`line_yield`
