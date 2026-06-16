# AI Chat Widget — 公版

獨立的 AI 問答視窗。右下角浮動泡泡 + 多 session sidebar + 圖文輸入,
**沒有跟特定專案綁定的邏輯**(不會跑 case 篩選、不會塞表格上下文),
任何 ASP.NET 4.x / IIS 站台都能丟下去用。

## 檔案

```
ai-chat-widget/
├── AiChat.aspx          ← 前端 (UI + JS) + 後端 code-behind 結合,直接是展示頁
├── AiChat.aspx.cs       ← 後端 chat proxy(讀 web.config 的 api-key 轉發到 LLM)
├── web.config           ← LLM endpoint / api-key / system prompt 設定
└── README.md            ← 你正在讀的這個檔
```

## 快速部署 (新站台)

1. **整個資料夾複製**到 IIS 站台目錄,例如
   `C:\inetpub\wwwroot\ai-chat\`
2. 編輯 `web.config`,把這幾個值填上:
   ```xml
   <add key="AiGatewayUrl"  value="http://10.11.197.97/openai/deployments/gpt-5.2/chat/completions" />
   <add key="AiApiKey"      value="你公司發給你的 key" />
   <add key="AiUserId"      value="員編,可選" />
   <add key="AiSystemPrompt" value="你想要的 system prompt" />
   ```
3. 瀏覽器開 `http://your-server/ai-chat/AiChat.aspx`
4. 看到右下角的 **AI** 圓鈕 → 點開就能聊天

## 嵌進既有的 ASP.NET 頁面

如果你有自己的頁面,想把這個小工具掛上去,只要做兩件事:

### 1. 後端(複製 `AiChat.aspx.cs` 邏輯到你站台)

最簡單:**直接把 `ai-chat-widget/` 整個資料夾放到你站台底下**,
你的頁面把 chat 請求送到 `/ai-chat/AiChat.aspx?op=chat` 就好。
不用改後端任何東西,你的主頁照舊。

### 2. 前端(把 UI 嵌進你的頁面)

打開 `AiChat.aspx`,複製這三段到你的 HTML:

| 段 | 位置 |
|---|---|
| `<style>...</style>` 整段 | 進你頁面的 `<head>` |
| `#aiBubble` 按鈕 + `#aiPanel` 整個 div | 進你頁面的 `<body>`(任何位置,position:fixed) |
| `<script>aiChatWidget IIFE</script>` | 進你頁面 `</body>` 前 |

然後在 `<script>` 前面加一段設定,告訴 widget proxy 在哪:

```html
<script>
    window.AiChatConfig = {
        proxyUrl: '/ai-chat/AiChat.aspx?op=chat',
        storageKey: 'myApp.aiSessions',
        activeKey:  'myApp.aiActiveId'
    };
</script>
```

`storageKey` / `activeKey` 自訂可以避免跟其他頁面的 widget 撞 localStorage。

## 設定值對照表

`web.config` 裡的 appSettings:

| key | 必填 | 說明 |
|---|---|---|
| `AiGatewayUrl` | ✅ | LLM gateway 的 URL(支援 OpenAI / Azure OpenAI 格式) |
| `AiApiKey` | ✅ | gateway 認證 key,**絕對不要 commit 進 git** |
| `AiUserId` | ❌ | 員編之類的識別,送 `user-id` header,有就送 |
| `AiSystemPrompt` | ❌ | system 訊息,沒設預設為 "You are a helpful assistant." |

`web.config` 的 `httpRuntime` 設了 50MB 上傳上限,讓 base64 大圖也吃得下。

## 功能

- 浮動圓鈕 (右下),點開 800×760 panel
- 左側 sidebar:多 session、新建、刪除、自訂標題、標籤
- 訊息泡(text / 圖片均可)、loading 動畫
- 圖片上傳:**迴紋針** / **Ctrl+V 貼上**
- 圖片自動縮到 1024 長邊 + JPEG 0.85,~200KB 不傷網路
- 點圖片放大到 95vw / 95vh(上限 2 倍原圖,不會糊)
- 對話歷史存 localStorage,重整、關 / 重開都還在
- Esc 關放大圖

## 安全性

- ✅ API key 只在 server 端讀,不會跑到瀏覽器
- ⚠️ 預設**沒有登入**,任何能到達 `?op=chat` 的人都能用
  → 想加閘門,在 `AiChat.aspx.cs` 的 `HandleChat()` 最前面加 token / IP 檢查
- ⚠️ HTTP 走的密碼明文,內網沒問題,要對外請上 HTTPS

## 後端編碼注意

`AiChat.aspx.cs` 是**純 ASCII**(包含 fallback 提示也是英文)。
所有中文都在 `web.config` 跟 `AiChat.aspx`,因為:
- `web.config` 有 `encoding="utf-8"` 宣告,部署轉碼不會壞
- `AiChat.aspx` 是 .aspx,有 `<%@ Page %>` directive,IIS 知道怎麼解
- 但 `AiChat.aspx.cs` 容易在複製過程被改成 ANSI / Big5,中文字串就會炸 CS1010
  ← 所以一律不寫中文

如果你要客製化錯誤訊息給使用者看,**在前端(JS)做翻譯**,後端只回英文 error code。
