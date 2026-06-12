# DB Connection 公版 (ASP.NET + SQL Server)

獨立的 SQL Server 連線範本。提供:

- **`DbHelper` 靜態類別** — 安全的參數化查詢 API,可在任何 .aspx code-behind 使用
- **`?op=rows&q=...` JSON 端點** — 前端 fetch 拿表格資料
- **展示頁** — 下拉選擇查詢、輸入參數、按執行,即時看結果

## 檔案

```
db-aspx/
├── DbDemo.aspx          ← 展示頁面 (HTML + JS)
├── DbDemo.aspx.cs       ← code-behind + DbHelper 類別
├── web.config           ← Connection string
└── README.md
```

## 快速部署

1. **複製整個資料夾**到 IIS 站台,例如 `C:\inetpub\wwwroot\db-demo\`
2. 編輯 `web.config` 把 `DefaultDb` 的 connection string 改成你自己的:
   ```xml
   <add name="DefaultDb"
        connectionString="Data Source=YOUR_SERVER;Initial Catalog=YOUR_DB;Integrated Security=True"
        providerName="System.Data.SqlClient" />
   ```
3. **IIS App Pool 身份必須有 DB 連線權限**(Integrated Security=True 時)
   - 如果用 SQL 帳號就改成 `User ID=xxx;Password=xxx`
4. 開瀏覽器 `http://your-server/db-demo/DbDemo.aspx`
5. 預設查詢 `getTables` 應該會列出 `sys.tables` 前 20 筆 → 確認連線通了

## 用法 — Server side (code-behind)

匯入 namespace 然後直接呼叫:

```csharp
// 多筆 → List<Dictionary<string, object>>
var rows = DbHelper.QueryRows(
    "SELECT id, name, score FROM students WHERE class = @p0 AND year = @p1",
    "3B", 2026
);
foreach (var r in rows)
{
    int id = (int)r["id"];
    string name = (string)r["name"];
}

// 單筆
var row = DbHelper.QueryOne("SELECT * FROM users WHERE id = @p0", 42);
if (row == null) { /* 找不到 */ }

// 純數值
int n = (int)DbHelper.QueryScalar("SELECT COUNT(*) FROM orders WHERE status = @p0", "open");

// INSERT / UPDATE / DELETE
int affected = DbHelper.Execute(
    "UPDATE products SET price = @p0 WHERE sku = @p1",
    99.5m, "ABC-123"
);
```

**參數**用 `@p0`, `@p1`, `@p2`,...,按順序傳。
**絕對不要**字串拼接 SQL — 一律走參數化,**自動防 SQL Injection**。

## 用法 — Client side (fetch JSON)

在 `DbDemo.aspx.cs` 的 `NamedQueries` 字典加你要的 SQL:

```csharp
private static readonly Dictionary<string, string> NamedQueries = new(...)
{
    { "getTables",  "SELECT TOP 20 name FROM sys.tables ORDER BY name" },
    { "getStudent", "SELECT id, name, score FROM students WHERE id = @p0" },
    { "topOrders",  "SELECT TOP @p0 id, total FROM orders ORDER BY total DESC" }
};
```

然後前端 fetch:

```js
const res = await fetch('DbDemo.aspx?op=rows&q=getStudent&p0=42');
const data = await res.json();
if (data.ok) {
    console.log(data.rows);   // [{id:42, name:"小明", score:88}]
}
```

`p0`, `p1`,... 用 query string 傳,server 自動綁定。

## 為什麼要走 NamedQueries 白名單

如果允許 client 直接傳 SQL → **任何人都能執行任意查詢甚至 DROP TABLE**。
所以 server 只允許**事先寫好的**查詢透過名稱呼叫,client 只能控制參數值。

要加新查詢 → 改 `DbDemo.aspx.cs` 重新部署。

## 換 DB engine (MySQL / Oracle / PostgreSQL)

`DbHelper` 寫死 `SqlConnection` / `SqlCommand`。要換引擎:

| 引擎 | 替換 |
|---|---|
| **MySQL** | `using MySql.Data.MySqlClient;` + `MySqlConnection` / `MySqlCommand`,需安裝 MySql.Data nuget |
| **Oracle** | `using Oracle.ManagedDataAccess.Client;` + `OracleConnection` / `OracleCommand`,需 Oracle.ManagedDataAccess.dll |
| **PostgreSQL** | `using Npgsql;` + `NpgsqlConnection` / `NpgsqlCommand`,需 Npgsql nuget |

整個檔案 search/replace 「Sql」→「MySql」(或對應 prefix)就好,API 都是 ADO.NET 標準。

如果要**同時支援多引擎**,改用 `DbProviderFactories.GetFactory(providerName)`,
從 `web.config` 的 `providerName` 動態挑 — 但程式碼會稍微長一點。

## 安全提醒

- ✅ **參數化查詢** → 防 SQL Injection
- ✅ **NamedQueries 白名單** → client 無法執行任意 SQL
- ⚠️ **沒有登入機制** — 任何能打到 `?op=rows` 的人都能查
  - 想加閘門:在 `Page_Load` 最前面檢查 `Request.Headers["X-Auth-Token"]` 或類似機制
- ⚠️ **App Pool 帳號的 DB 權限**就是 web 能做的最大權限
  - 建議用**唯讀帳號**(只給 `db_datareader` 角色),DB 修改要走 stored procedure

## DateTime 處理

`DbHelper.QueryRows` 把 `DateTime` 統一轉成 **ISO 8601 字串**(`"o"` 格式),
這樣 JSON 直接是 `"2026-06-12T04:00:00.0000000Z"`,前端 `new Date(s)` 就能 parse。
比 `JavaScriptSerializer` 預設的 `"\/Date(123456789)\/"` 友善得多。

## NULL 值

DB 的 `NULL` → C# 端是 `null`(已從 `DBNull.Value` 轉好) → JSON 是 `null`。
前端 `data.rows[0].col === null` 直接判斷就行。
