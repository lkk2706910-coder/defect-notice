# web-template-lite — 無登入版 (AI + DB)

`web-template` 的精簡版,**拿掉登入機制**,只保留:
- 一個首頁(右下角內嵌 AI 助理)
- `DbHelper` 參數化 SQL 工具

任何人開網址就能用,**適合公司內部、已經有其他層存取控管的環境**。
如果是對外網路要的話,請用完整版 `web-template/`(有 login + token)。

## 檔案

```
web-template-lite/
├── web.config            ← Connection string + AI gateway 設定
├── Home.aspx             ← 首頁 + AI chat panel
├── Home.aspx.cs          ← AI chat 代理 (沒有 auth gate)
└── App_Code/
    └── DbHelper.cs       ← 參數化 SQL 工具
```

## 部署 3 步

1. 複製整個資料夾到 IIS(`C:\inetpub\wwwroot\my-app\` 等),建議轉成 IIS Application。
2. 改 `web.config`:
   - `DefaultDb` connection string 改成你的 SQL Server。
   - `AiGatewayUrl` / `AiApiKey` 填好。`AiApiKey` **不要 commit**,只在部署機填真值。
3. 開 `http://your-server/my-app/Home.aspx` 看到首頁,右下角 AI 圓鈕點開就能對話。

## 加新頁面

新建任何 `.aspx`,沒有 auth gate 要繞:

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    // 直接寫你的邏輯,要 DB 就用 DbHelper
}
```

## 用 DbHelper 查 DB

任何 `.cs` 都能直接呼叫:

```csharp
// 多筆
var rows = DbHelper.QueryRows(
    "SELECT id, name FROM Products WHERE category = @p0 AND price < @p1",
    "books", 100
);
foreach (var r in rows)
{
    int id    = (int)r["id"];
    string nm = (string)r["name"];
}

// 單筆
var row = DbHelper.QueryOne("SELECT * FROM Users WHERE Username = @p0", "admin");

// 純數值
int n = (int)DbHelper.QueryScalar("SELECT COUNT(*) FROM Orders");

// INSERT / UPDATE / DELETE
DbHelper.Execute("UPDATE Orders SET status = @p0 WHERE id = @p1", "shipped", 42);
```

`@p0`, `@p1`,... 是位置參數,**自動參數化、防 SQL Injection**。
不要把使用者輸入用字串接到 SQL 裡。

## 移除 AI 助理

不想要右下角圓鈕:
- `Home.aspx` 把 `#aiBubble` / `#aiPanel` 兩段 HTML 刪掉
- `<style>` 裡 AI 相關段落可以一起刪
- 最底下 `<script>` IIFE 全部刪掉
- `Home.aspx.cs` 的 `HandleChat()` + `op=chat` 分支也可以刪

## 跟完整版 (`web-template/`) 的差異

| 項目 | lite | 完整 |
|---|---|---|
| 登入畫面 | ❌ 沒有 | ✅ Login.aspx |
| Users 表 + db-schema.sql | ❌ 沒有 | ✅ Users + admin/admin123 |
| HttpOnly cookie token | ❌ 沒有 | ✅ 有 |
| AuthHelper.cs | ❌ 沒有 | ✅ Hash + 驗證 + token |
| AI chat | ✅ 有(直接代理) | ✅ 有(代理 + auth gated) |
| DbHelper | ✅ 有 | ✅ 有 |

## 換成 MySQL / Oracle / PostgreSQL

`DbHelper.cs` 只用 `System.Data.SqlClient`。換引擎:
- `using MySql.Data.MySqlClient;` + `MySql*` (要裝 MySql.Data)
- `using Oracle.ManagedDataAccess.Client;` + `Oracle*`
- `using Npgsql;` + `Npgsql*`
