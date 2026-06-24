<%@ Page Language="C#" AutoEventWireup="true" Inherits="Home" CodeFile="Home.aspx.cs" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Login + Edit Permission 範本</title>
    <style>
        :root {
            color-scheme: dark;
            --bg: #0b1220;
            --panel: #0f1b33;
            --panel-elevated: #14233f;
            --text: #f3f7ff;
            --muted: #c6d0e6;
            --border: rgba(255,255,255,0.12);
            --tint-med: rgba(255,255,255,0.06);
            --tint-high: rgba(255,255,255,0.10);
            --accent: #63b3ed;
            --accent-strong: #2563eb;
            --input-bg: rgba(5,10,20,0.30);
            --warn: #fbbf24;
            --warn-bg: rgba(251,191,36,0.10);
            --warn-border: rgba(251,191,36,0.40);
            --danger: #fca5a5;
            --ok: #34d399;
        }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; }
        body {
            font-family: -apple-system, "Segoe UI", "Noto Sans TC", sans-serif;
            background: var(--bg); color: var(--text); min-height: 100vh;
        }
        .topbar {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 22px;
            background: var(--panel); border-bottom: 1px solid var(--border);
        }
        .topbar h1 { font-size: 16px; margin: 0; }
        .topbar .who { margin-left: auto; color: var(--muted); font-size: 13px; }
        .topbar .who .role {
            background: var(--tint-med); padding: 2px 8px; border-radius: 999px;
            font-size: 11px; margin-left: 6px; color: var(--text);
        }
        .wrap { max-width: 960px; margin: 0 auto; padding: 24px; }
        .card {
            background: var(--panel); border: 1px solid var(--border);
            border-radius: 12px; padding: 18px 20px; margin-bottom: 18px;
        }
        .card h2 { font-size: 16px; margin: 0 0 8px; }
        .card p  { color: var(--muted); line-height: 1.6; margin: 0 0 8px; }
        code { background: var(--tint-med); padding: 2px 6px; border-radius: 4px; font-size: 13px; }

        /* Mode toggle pill */
        .toolbar { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
        .btn {
            background: var(--tint-med); color: var(--text);
            border: 1px solid var(--border); border-radius: 999px;
            padding: 6px 14px; cursor: pointer; font-size: 13px;
        }
        .btn:hover { background: var(--tint-high); border-color: var(--accent); }
        .btn.primary { background: var(--accent); border-color: var(--accent); color: #fff; }
        .btn.primary:hover { background: var(--accent-strong); border-color: var(--accent-strong); }
        .btn.warn { background: var(--warn-bg); color: var(--warn); border-color: var(--warn-border); }
        .mode-pill {
            padding: 6px 14px; border-radius: 999px; font-size: 13px;
            border: 1px solid var(--border); background: var(--tint-med);
            cursor: pointer;
        }
        .mode-pill.editing { background: rgba(99,179,237,0.18); border-color: var(--accent); color: var(--accent); }
        .mode-pill.viewing { color: var(--warn); border-color: var(--warn-border); background: var(--warn-bg); }

        /* Edit-mode-only controls hide in view mode */
        body.view-mode .editor-only { display: none !important; }
        body:not(.view-mode) .viewer-only { display: none !important; }

        /* Editable demo field */
        .demo-input {
            display: block; width: 100%; padding: 8px 10px;
            background: var(--input-bg); color: var(--text);
            border: 1px solid var(--border); border-radius: 6px;
            font-size: 13px; outline: none; margin-top: 8px;
        }
        .demo-input:focus { border-color: var(--accent); }
        .demo-input:read-only { background: transparent; border-style: dashed; color: var(--muted); }
        .status { color: var(--muted); font-size: 12px; margin-top: 8px; min-height: 16px; }
        .status.ok { color: var(--ok); }
        .status.err { color: var(--warn); }

        /* Login modal */
        .modal-mask {
            position: fixed; inset: 0; background: rgba(0,0,0,0.65);
            display: none; align-items: center; justify-content: center;
            z-index: 9999;
        }
        .modal-mask.open { display: flex; }
        .modal {
            width: 360px; background: var(--panel-elevated);
            border: 1px solid var(--border); border-radius: 12px;
            padding: 22px 22px 18px;
        }
        .modal h3 { font-size: 16px; margin: 0 0 12px; }
        .modal label { display: block; font-size: 12px; color: var(--muted); margin-top: 10px; }
        .modal input {
            display: block; width: 100%; padding: 8px 10px; margin-top: 4px;
            background: var(--input-bg); color: var(--text);
            border: 1px solid var(--border); border-radius: 6px;
            font-size: 13px; outline: none;
        }
        .modal input:focus { border-color: var(--accent); }
        .modal .err { color: var(--warn); font-size: 12px; min-height: 16px; margin-top: 8px; }
        .modal .actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 14px; }
    </style>
</head>
<body class="view-mode">
    <div class="topbar">
        <h1>Login + Edit Permission 範本</h1>
        <span class="who" id="whoami">未登入</span>
        <button type="button" class="btn editor-only" id="btnLogout" title="登出">登出</button>
        <button type="button" class="mode-pill viewing" id="modeToggle">唯讀中 — 點此編輯</button>
    </div>

    <div class="wrap">
        <div class="card">
            <h2>怎麼用</h2>
            <p>頁面預設為<strong>唯讀模式</strong>(任何人都看得到)。按右上角「點此編輯」會跳出登入視窗;
                帳號驗證走 <code>App_Data/users.json</code>。登入後依角色變化:</p>
            <p>
                <code>editor</code>:UI 解鎖,可呼叫 <code>?op=save</code> 等 mutating ops。<br />
                <code>viewer</code>:UI 仍然唯讀,試圖呼叫 mutating ops 會被 <code>RequireEditor</code> 擋掉。
            </p>
            <p>Token 8 小時 sliding 過期,任何成功請求都會自動續期。token 失效時,<code>authFetch</code>
                會自動把唯讀界面跳出來重新登入,但<strong>不會清掉你在編輯的本地資料</strong>(那段 bug 已修)。</p>
        </div>

        <div class="card">
            <h2>Demo:可編輯欄位</h2>
            <p class="viewer-only" style="color: var(--warn);">⚠ 唯讀模式中,輸入框被鎖。點右上角「點此編輯」登入。</p>
            <label>備註</label>
            <input type="text" class="demo-input" id="demoText" value="Hello, world." />
            <div class="toolbar editor-only" style="margin-top: 10px;">
                <button type="button" class="btn primary" id="btnSave">儲存(走 RequireEditor)</button>
                <span class="status" id="saveStatus"></span>
            </div>
        </div>

        <div class="card">
            <h2>怎麼把保護加到別的 .aspx</h2>
            <p>在新頁的 code-behind 開頭:</p>
            <p><code>if (!AuthHelper.RequireAuth(HttpContext.Current)) { Response.End(); return; }</code></p>
            <p>會寫入的 op 改用:</p>
            <p><code>if (!AuthHelper.RequireEditor(HttpContext.Current)) { Response.End(); return; }</code></p>
            <p>失敗會直接寫 <code>{"ok":false,"error":"needLogin"}</code> 或 <code>"readonly"</code>,
                客戶端 <code>authFetch</code> 看到 <code>needLogin</code> 會自動彈出登入視窗。</p>
        </div>
    </div>

    <!-- Login modal -->
    <div class="modal-mask" id="loginMask">
        <div class="modal">
            <h3 id="loginTitle">進入編輯模式</h3>
            <form id="loginForm" autocomplete="on">
                <label>使用者</label>
                <input type="text" id="loginUser" autocomplete="username" required />
                <label>密碼</label>
                <input type="password" id="loginPwd" autocomplete="current-password" required />
                <div class="err" id="loginErr"></div>
                <div class="actions">
                    <button type="button" class="btn" id="loginCancel">取消</button>
                    <button type="submit" class="btn primary" id="loginSubmit">登入</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // =====================================================================
        //  Login + Edit Permission template, frontend bits.
        //  Talks to this same Home.aspx via ?op=login / ?op=whoami / ?op=save.
        // =====================================================================
        (function () {
            const $ = id => document.getElementById(id);

            // Session storage (per-tab, cleared when tab closes). Use
            // localStorage if you want users to stay logged in across tabs.
            const TOKEN_KEY = 'webtmpl.authToken';
            const USER_KEY  = 'webtmpl.authUser';
            const ROLE_KEY  = 'webtmpl.authRole';

            function getToken() { try { return sessionStorage.getItem(TOKEN_KEY) || ''; } catch (e) { return ''; } }
            function getUser()  { try { return sessionStorage.getItem(USER_KEY)  || ''; } catch (e) { return ''; } }
            function getRole()  { try { return sessionStorage.getItem(ROLE_KEY)  || ''; } catch (e) { return ''; } }
            function setSession(t, u, r) {
                try {
                    sessionStorage.setItem(TOKEN_KEY, t || '');
                    sessionStorage.setItem(USER_KEY,  u || '');
                    sessionStorage.setItem(ROLE_KEY,  r || '');
                } catch (e) {}
            }
            function clearSession() {
                try {
                    sessionStorage.removeItem(TOKEN_KEY);
                    sessionStorage.removeItem(USER_KEY);
                    sessionStorage.removeItem(ROLE_KEY);
                } catch (e) {}
            }

            // -------- authFetch --------
            // Wraps fetch() to:
            //  1. attach the auth token in X-Auth-Token
            //  2. detect the {ok:false, error:"needLogin"} sentinel and
            //     auto-pop the login modal so the user can re-auth without
            //     losing whatever they were doing
            // Note: we look at the response body, NOT the HTTP status, because
            // the backend deliberately returns HTTP 200 with that JSON to
            // avoid IIS Classic's WWW-Authenticate prompt.
            async function authFetch(url, opts) {
                opts = opts || {};
                const headers = Object.assign({}, opts.headers || {});
                const tok = getToken();
                if (tok) headers['X-Auth-Token'] = tok;
                const res = await fetch(url, Object.assign({}, opts, { headers: headers }));
                try {
                    const peek = await res.clone().json();
                    if (peek && peek.ok === false && peek.error === 'needLogin') {
                        // Soft-logout: clear creds but DO NOT wipe form state.
                        // Pop the modal; on success, just continue what the
                        // user was doing.
                        clearSession();
                        applyMode(true);
                        openLogin('登入逾期,請重新登入', null);
                    }
                } catch (e) { /* not JSON; ignore */ }
                return res;
            }

            // -------- Mode + UI --------
            function isViewer() { return getRole() === 'viewer'; }

            function applyMode(forceViewMode) {
                // viewMode=true means "no edit privilege right now". Either
                // because not logged in, or logged in as viewer, or user
                // explicitly toggled back to read-only.
                let view = forceViewMode;
                if (view === undefined) view = !getToken() || isViewer();
                document.body.classList.toggle('view-mode', view);
                $('demoText').readOnly = view;

                const pill = $('modeToggle');
                if (view) {
                    pill.className = 'mode-pill viewing';
                    if (!getToken())  pill.textContent = '唯讀中 — 點此編輯';
                    else if (isViewer()) pill.textContent = '唯讀帳號 — 無編輯權限';
                    else              pill.textContent = '唯讀中 — 點此編輯';
                } else {
                    pill.className = 'mode-pill editing';
                    pill.textContent = '編輯中 — 點此唯讀';
                }
                $('whoami').innerHTML = getToken()
                    ? (escapeHtml(getUser()) + '<span class="role">' + escapeHtml(getRole() || 'editor') + '</span>')
                    : '未登入';
            }

            function escapeHtml(s) {
                return (s || '').replace(/[&<>"']/g, c => ({
                    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
                }[c]));
            }

            // -------- Login modal --------
            let pendingAfterLogin = null;
            function openLogin(title, onSuccess) {
                pendingAfterLogin = onSuccess || null;
                if (title) $('loginTitle').textContent = title;
                else $('loginTitle').textContent = '進入編輯模式';
                $('loginErr').textContent = '';
                $('loginMask').classList.add('open');
                setTimeout(() => $('loginUser').focus(), 0);
            }
            function closeLogin() {
                $('loginMask').classList.remove('open');
                $('loginPwd').value = '';
                pendingAfterLogin = null;
            }
            $('loginCancel').addEventListener('click', closeLogin);
            $('loginMask').addEventListener('click', e => {
                if (e.target === $('loginMask')) closeLogin();
            });
            $('loginForm').addEventListener('submit', async e => {
                e.preventDefault();
                $('loginErr').textContent = '';
                const u = $('loginUser').value.trim();
                const p = $('loginPwd').value;
                if (!u || !p) { $('loginErr').textContent = '帳號或密碼空白'; return; }
                try {
                    const res = await fetch('Home.aspx?op=login', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json; charset=utf-8' },
                        body: JSON.stringify({ username: u, password: p })
                    });
                    const data = await res.json();
                    if (data && data.ok) {
                        setSession(data.token, data.name, data.role);
                        applyMode(isViewer());
                        const cb = pendingAfterLogin;
                        closeLogin();
                        if (typeof cb === 'function') cb();
                    } else {
                        const err = (data && data.error) || ('HTTP ' + res.status);
                        $('loginErr').textContent =
                            err === 'bad_credentials' ? '帳號或密碼不對' :
                            err === 'empty_fields'    ? '帳號或密碼空白'   :
                            err;
                    }
                } catch (ex) {
                    $('loginErr').textContent = '網路錯誤: ' + ex.message;
                }
            });

            // -------- Mode toggle + logout --------
            $('modeToggle').addEventListener('click', () => {
                if (!getToken()) { openLogin(null, null); return; }
                if (isViewer()) { alert('此帳號為唯讀,無編輯權限'); return; }
                // Toggle between view and edit (both states are post-login)
                const nowView = document.body.classList.contains('view-mode');
                applyMode(!nowView ? true : false);
            });
            $('btnLogout').addEventListener('click', () => {
                if (!confirm('登出?')) return;
                clearSession();
                applyMode(true);
            });

            // -------- Demo save --------
            $('btnSave').addEventListener('click', async () => {
                const txt = $('demoText').value;
                $('saveStatus').textContent = '儲存中...';
                $('saveStatus').className = 'status';
                try {
                    const res = await authFetch('Home.aspx?op=save', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json; charset=utf-8' },
                        body: JSON.stringify({ text: txt })
                    });
                    const data = await res.json();
                    if (data && data.ok) {
                        $('saveStatus').textContent = '已儲存,by ' + data.editedBy;
                        $('saveStatus').className = 'status ok';
                    } else if (data && data.error === 'readonly') {
                        $('saveStatus').textContent = '此帳號為唯讀,無編輯權限';
                        $('saveStatus').className = 'status err';
                    } else if (data && data.error === 'needLogin') {
                        $('saveStatus').textContent = '登入已逾期,請重新登入';
                        $('saveStatus').className = 'status err';
                    } else {
                        $('saveStatus').textContent = '儲存失敗: ' + (data && data.error || 'unknown');
                        $('saveStatus').className = 'status err';
                    }
                } catch (e) {
                    $('saveStatus').textContent = '網路錯誤: ' + e.message;
                    $('saveStatus').className = 'status err';
                }
            });

            // -------- Boot --------
            // If we have a stale token from a previous tab, ask the server.
            // Server says no -> clear session silently.
            async function bootCheck() {
                if (!getToken()) { applyMode(true); return; }
                try {
                    const res = await authFetch('Home.aspx?op=whoami');
                    const data = await res.json();
                    if (data && data.ok) {
                        setSession(getToken(), data.name, data.role);
                        applyMode(isViewer());
                    } else {
                        clearSession();
                        applyMode(true);
                    }
                } catch (e) {
                    applyMode(true);
                }
            }
            bootCheck();
        })();
    </script>
</body>
</html>
