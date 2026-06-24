# login-edit-template — Login + 編輯權限 範本

ASP.NET WebForms (.NET 4.x) 用的「登入 + 編輯權限」範本,從正式上線的
Line Yield 系統抽出來的最終版本,**已包含所有實戰修過的 bug**:

- ✅ 永遠回 HTTP 200,不回 401 — 避免 IIS Classic mode 自動加 `WWW-Authenticate` 彈瀏覽器原生視窗
- ✅ Token 8 小時 **sliding expiry**(成功 request 自動續期)
- ✅ Sliding 過期時,client 端 `authFetch` 自動彈登入視窗、**不會清掉使用者在編輯的本地資料**
- ✅ Editor / Viewer 兩種角色,viewer 進得來但不能 mutate
- ✅ SHA-256 + per-user salt + **constant-time hash 比對**(防 timing attack)
- ✅ Token 字典 GC(每次成功登入會清掉過期 token,記憶體不會無上限增長)
- ✅ 完整的 view-mode / edit-mode 切換,登入後可以隨時切回唯讀預覽

## 檔案

```
login-edit-template/
├── web.config                    最小設定
├── Home.aspx                     範例頁面 (含登入 modal + view/edit 切換)
├── Home.aspx.cs                  範例 routes,展示 RequireAuth / RequireEditor
├── App_Code/
│   └── AuthHelper.cs             ★ 核心:token 表 + login + 角色 gate
├── App_Data/
│   └── users.json                ★ 帳號清單 (sample: admin/admin123, reader/reader123)
├── tools/
│   └── user_hash.py              ★ 帳號 hash 產生工具(GUI + Excel 批次)
└── README.md
```

## 部署 4 步

### 1. 把整個資料夾複製到 IIS

例如 `C:\inetpub\wwwroot\my-app\`。**建議轉成 IIS Application**(避免和上層
`App_Code` 衝突)。

### 2. 把預設密碼換掉

把 `App_Data/users.json` 裡的 admin / reader **馬上換成自己的帳號**。
最快做法:

```cmd
python tools\user_hash.py
```

GUI 模式輸入帳號 / 密碼 / 權限 → 產生 JSON → 直接寫進 `App_Data/users.json`。
批次:Excel 範本一次匯入多筆(同名覆蓋 = 改密碼)。

### 3. 開瀏覽器

`http://your-server/my-app/Home.aspx`
- 看到頁面 = 唯讀模式(任何人都看得到)
- 按右上角「點此編輯」→ 登入視窗
- 用 admin / admin123 登入 → UI 解鎖
- 用 reader / reader123 登入 → UI 仍鎖,試圖按「儲存」會被擋

### 4. 把 4 步驟整合到你自己的頁面

下節說明。

## 把保護加到你自己的頁面

新建任何 `.aspx`,在 code-behind 開頭依需求加一行:

```csharp
// 純讀取的 op
if (!AuthHelper.RequireAuth(HttpContext.Current)) { Response.End(); return; }

// 會寫入 / 改資料的 op
if (!AuthHelper.RequireEditor(HttpContext.Current)) { Response.End(); return; }
```

兩者失敗時都會直接寫好 JSON 失敗回應(`{"ok":false,"error":"needLogin"}`
或 `"readonly"`)並回傳 false,**呼叫端就 `return;` 結束**。HTTP 狀態
碼一律是 200,前端 `authFetch` 看到 `error:"needLogin"` 會自動處理。

要拿登入者名稱:

```csharp
string user = AuthHelper.CurrentUser(HttpContext.Current);
string role = AuthHelper.CurrentRole(HttpContext.Current);
```

## 把登入功能 / `authFetch` 接到你自己的前端

`Home.aspx` 裡面的 IIFE 已經完整示範了所有部分。要搬到別的頁面就把以下
複製過去:

1. **`.modal-mask` 整段 HTML + CSS** — 登入視窗
2. **`<script>` IIFE 裡的整段 JS** — `authFetch` / `openLogin` / 模式切換
3. **`body.view-mode .editor-only / .viewer-only` 兩條 CSS** — 用來自動
   隱藏編輯模式 UI(隨身物件:加 class 給按鈕 / 表格欄位即可)

之後所有 API 呼叫一律走 `authFetch(url, opts)`(取代 `fetch`),會自動:
- 附 `X-Auth-Token` header
- 攔截 `needLogin` 回應,清掉 token + 彈登入視窗
- **不清掉**你的編輯狀態(因為登入修好後使用者要繼續做)

## 帳號管理

GUI 工具 `tools/user_hash.py`:
- 單筆:填欄位 → 產生 JSON → 「寫進 users.json」自動合併到既有檔
- 批次:下載 Excel 範本 → Excel 填多筆 → 匯入 → 批次寫入
- 同名帳號覆蓋 = 改密碼,其他帳號不動

直接寫 SQL / 改 JSON 的話,格式:

```json
{
  "users": [
    {
      "name": "alice",
      "salt": "16字元 URL-safe base64",
      "hash": "base64(SHA-256(salt + password))",
      "role": "editor 或 viewer"
    }
  ]
}
```

- `salt`:每個人一個,不能複用
- `hash`:`base64(SHA-256(UTF-8(salt + password)))`,與 `AuthHelper.Sha256B64` 一致
- `role`:`editor` 或 `viewer`,沒設預設為 `editor`(向前相容)

## 安全等級對照

| 項目 | 狀態 |
|---|---|
| Hash + Salt 密碼 | ✅ SHA-256 + per-user salt |
| Constant-time hash 比對 | ✅ 防 timing attack |
| 防 SQL Injection | ✅ 不打 DB / 沒有 SQL |
| Token in HttpOnly cookie | ❌ 用 sessionStorage(JS 可讀,但 token 不會跨 tab 留) |
| Token 過期 | ✅ 8h sliding |
| Token GC | ✅ 每次登入會清過期項目 |
| Token 跨 IIS recycle 保留 | ❌ 記憶體 dict — recycle 時所有人下線 |
| HTTPS | ❌ web.config 沒強制 — 走 prod 請 IT 上 HTTPS |
| 連續錯誤鎖帳號 | ❌ 沒做 — 要的話加在 `AuthHelper.HandleLogin` |
| Refresh token | ❌ 沒做 — 8h 過期後重新登入 |

**這個範本適合內部、低風險的網頁應用**(產線輔助、設備工程小工具等)。
要對外服務,加 HTTPS + 連續失敗鎖帳號 + token 寫 DB 至少這三件事。

## 為什麼是 sessionStorage 不是 cookie

設計選擇 — 不是必然,可以替換:
- ✅ 安全:cookie 容易被 CSRF;X-Auth-Token header **必須由 JS 主動加**,
  跨站表單偽造不會自動帶
- ✅ 多 tab 獨立:每個 tab 一個登入狀態,適合「在另一個 tab 開唯讀預覽」的場景
- ❌ 缺點:F5 / 重開 tab 要重新登入

要改成 cookie:
1. `AuthHelper.HandleLogin` 用 `Response.Cookies.Add(...)` 寫 HttpOnly cookie
2. `RequireAuth` 改成讀 `Request.Cookies["site_auth"].Value`
3. 客戶端 `authFetch` 拿掉 `X-Auth-Token` 那段,改用 `credentials: 'include'`

## 常見問題

**Q: 登入後馬上又跳回登入畫面**
A: 通常是 `bootCheck()` 打 `?op=whoami` 拿到 needLogin。檢查:
- IIS App Pool recycle 過了 → 所有 token 都清空。正常,重新登入即可。
- F12 → Application → Session Storage 看 `webtmpl.authToken` 有沒有值。

**Q: 編譯錯誤 CS1010 "Newline in constant"**
A: `.cs` 檔案被改成非 UTF-8 編碼了。所有 `.cs` 都**設計成純 ASCII**,不要
手動編輯加中文。中文一律放在 `.aspx`(UTF-8) 或 `web.config`。

**Q: 改成 Windows AD 帳號驗證**
A: 把 `AuthHelper.HandleLogin` 的密碼比對段換成
`new DirectoryEntry("LDAP://...", username, password).NativeObject`(成功就過,
失敗丟 `COMException`)。其他 token / 過期邏輯都不用動。
