# Web Template 公版 — Login + SQL Server + AI Chat 全包

下載這個資料夾,改 `web.config` 的 connection string,跑一次 `db-schema.sql`,
就有一個**完整可用**的網頁:
- 進站要登入(帳號密碼從 SQL Server `Users` 表驗證)
- 登入後右下角有 AI 助理(LLM 透過後端 proxy,API key 藏在 server)
- Token 8 小時 sliding expiry,HttpOnly cookie(JS 偷不到)

## 檔案結構

```
web-template/
├── web.config              ← Connection string + AI gateway 設定
├── db-schema.sql           ← CREATE TABLE Users + 預設 admin/admin123
├── Login.aspx              ← 登入畫面
├── Login.aspx.cs           ← 驗證使用者、發 cookie
├── Home.aspx               ← 登入後首頁(內嵌 AI chat panel)
├── Home.aspx.cs            ← 守門 + 登出 + AI chat proxy
├── App_Code/
│   ├── DbHelper.cs         ← 參數化 SQL 查詢工具(全頁共用)
│   └── AuthHelper.cs       ← Hash + 驗證 + token 管理
└── README.md
```

## 部署 4 步

### 步驟 1 — 複製整個資料夾到 IIS

`C:\inetpub\wwwroot\my-app\` 之類的位置。建議**轉成 IIS Application**(避免和上層 App_Code 衝突)。

### 步驟 2 — 改 `web.config`

```xml
<connectionStrings>
    <add name="DefaultDb"
         connectionString="Data Source=YOUR_SERVER;Initial Catalog=YOUR_DB;Integrated Security=True"
         providerName="System.Data.SqlClient" />
</connectionStrings>
<appSettings>
    <add key="AiGatewayUrl"    value="http://你的 LLM gateway/chat/completions" />
    <add key="AiApiKey"        value="你的 key (不要 commit)" />
    <add key="AiSystemPrompt"  value="你想要的 prompt" />
</appSettings>
```

### 步驟 3 — 跑 `db-schema.sql`

用 SSMS 或 sqlcmd 連到你的 DB,跑一次 `db-schema.sql`。
建好 `Users` 表 + 寫入預設帳號 `admin / admin123`。

### 步驟 4 — 開瀏覽器

`http://your-server/my-app/Login.aspx`
- 輸入 **admin / admin123** 登入
- 進到 Home 後**馬上改密碼**(見下節)

## 改密碼 / 加新使用者

最簡單(暫時用):**直接寫 SQL**。

先用 Python tool 算 hash(在主專案的 `tools/user_hash.py`):
```cmd
python tools\user_hash.py
```
- 輸入帳號 / 密碼 → 「產生 JSON」
- 從 JSON 抄 salt + hash

然後在 DB 跑:
```sql
-- 加新使用者
INSERT INTO Users (Username, Salt, PasswordHash)
VALUES ('alice', '<salt-from-tool>', '<hash-from-tool>');

-- 改既有使用者密碼
UPDATE Users SET Salt = '<new-salt>', PasswordHash = '<new-hash>'
WHERE Username = 'admin';

-- 停用 / 啟用
UPDATE Users SET Enabled = 0 WHERE Username = 'someone';
```

之後要做的話,可以加一個 `Users.aspx` 管理頁 — 留給你客製。

## 在你的頁面加保護

新建任何 `.aspx`,在 `Page_Load` 開頭加:

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    var me = AuthHelper.ReadCurrent();
    if (me == null) { Response.Redirect("Login.aspx", true); return; }
    // 後面就能用 me.Username
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

## 安全等級

| 項目 | 狀態 |
|---|---|
| Hash + Salt 密碼 | ✅ SHA-256 + per-user salt |
| HttpOnly cookie | ✅ JS 偷不到 token (防 XSS) |
| 防 SQL Injection | ✅ 全參數化 |
| Constant-time hash 比對 | ✅ 防 timing attack |
| Token 過期 | ✅ 8 小時 sliding expiry |
| HTTPS | ❌ 預設 HTTP,生產上要請 IT 上憑證 |
| 連續錯誤鎖帳號 | ❌ 沒做,要的話加在 `AuthHelper.TryLogin` |
| Token 跨 IIS recycle 保留 | ❌ 記憶體存,recycle 就全員下線(可改 DB 存) |

## 換成 MySQL / Oracle / PostgreSQL

`DbHelper.cs` 跟 `Login.aspx.cs` 都只用 `System.Data.SqlClient`。換引擎:
- `using MySql.Data.MySqlClient;` + `MySql*` (要裝 MySql.Data)
- `using Oracle.ManagedDataAccess.Client;` + `Oracle*`
- `using Npgsql;` + `Npgsql*`

`db-schema.sql` 也要照對應方言改 (`NVARCHAR` → MySQL `VARCHAR`, etc.)

## 移除 AI 助理

不想要右下角的 AI 圓鈕:
- `Home.aspx` 把 `#aiBubble` / `#aiPanel` 兩段 HTML 刪掉
- `<style>` 裡 AI 相關的段落可以一起刪
- `<script>` 最底下 IIFE 刪掉
- `Home.aspx.cs` 的 `HandleChat()` + `op=chat` 分支可以留(沒人打就沒影響)或一起刪

## 常見問題

**Q: 帳號密碼錯誤但密碼明明對**
A: 對照 `db-schema.sql` 預設 admin 那段,你算的 hash 演算法要是 `base64(SHA-256(UTF-8(salt + password)))`。
用 `tools/user_hash.py` 算最保險。

**Q: 登入後馬上又回到登入頁**
A: 通常是 cookie 沒寫到瀏覽器。檢查:
- IIS App Pool 帳號有沒有寫 cookie 權限(基本上一定有)
- 你的網址有沒有跨子網域 / 跨 protocol(cookie 預設綁同源)
- F12 → Application → Cookies 看 `site_auth` 有沒有出現

**Q: 編譯錯誤 CS1010 Newline in constant**
A: `.cs` 檔案被改成非 UTF-8 編碼了。請用 git pull(不要手動 copy)。
所有 `.cs` 都是純 ASCII 設計,只有 `.aspx` 跟 `web.config` 有中文。

**Q: IIS recycle 後所有人被踢出**
A: 預期行為(token 在記憶體)。要 token 跨 recycle 保留:
做一張 `Sessions` 表,改 `AuthHelper._tokens` 讀寫 DB。
