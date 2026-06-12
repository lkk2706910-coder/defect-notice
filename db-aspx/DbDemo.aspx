<%@ Page Language="C#" AutoEventWireup="true" Inherits="DbDemo" CodeFile="DbDemo.aspx.cs" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>DB Connection Demo</title>
    <style>
        :root {
            color-scheme: light;
            --bg: #f4f6fb;
            --panel: #ffffff;
            --text: #1a2542;
            --muted: #5a6b8c;
            --border: rgba(0,0,0,0.10);
            --accent: #2563eb;
            --warn-bg: #fffbeb;
            --warn-border: #f59e0b;
            --warn: #b45309;
        }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans TC", Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            padding: 24px;
        }
        .wrap { max-width: 1100px; margin: 0 auto; }
        h1 { font-size: 22px; margin: 0 0 4px; }
        .lede { color: var(--muted); margin: 0 0 18px; line-height: 1.55; }
        code { background: rgba(0,0,0,0.06); padding: 2px 6px; border-radius: 4px; font-size: 13px; }

        .toolbar {
            display: flex; gap: 8px; align-items: center;
            margin-bottom: 14px;
            padding: 10px 12px;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 10px;
        }
        .toolbar label { font-size: 12px; color: var(--muted); }
        .toolbar select, .toolbar input[type="text"] {
            padding: 6px 10px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-size: 13px;
            background: #fff;
            color: var(--text);
            outline: none;
        }
        .toolbar input[type="text"] { width: 180px; }
        .toolbar select:focus, .toolbar input:focus { border-color: var(--accent); }
        .toolbar button {
            padding: 6px 14px;
            background: var(--accent); color: #fff;
            border: 1px solid var(--accent);
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
        }
        .toolbar button:hover { background: #1d4ed8; }
        .toolbar .status { margin-left: auto; font-size: 12px; color: var(--muted); }

        .panel {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 10px;
            overflow: hidden;
        }
        table.rows { width: 100%; border-collapse: collapse; font-size: 13px; }
        table.rows th, table.rows td { padding: 8px 12px; border-bottom: 1px solid var(--border); text-align: left; vertical-align: top; }
        table.rows th { background: #fafbfd; font-weight: 600; position: sticky; top: 0; }
        table.rows tr:hover { background: rgba(37,99,235,0.05); }
        table.rows td .null { color: var(--muted); font-style: italic; }
        .err {
            margin: 14px 0;
            padding: 10px 14px;
            background: var(--warn-bg);
            border: 1px solid var(--warn-border);
            color: var(--warn);
            border-radius: 8px;
            font-size: 13px;
            white-space: pre-wrap;
            word-break: break-word;
        }
    </style>
</head>
<body>
    <div class="wrap">
        <h1>DB Connection Demo</h1>
        <p class="lede">公版 SQL Server 連線範本。
            <code>web.config</code> 設好 <code>DefaultDb</code> connection string,
            <code>DbDemo.aspx.cs</code> 的 <code>NamedQueries</code> 字典加你要的 SQL,
            就能用 <code>?op=rows&amp;q=查詢名</code> 拿 JSON。</p>

        <div class="toolbar">
            <label for="qSelect">查詢</label>
            <select id="qSelect">
                <option value="getTables">getTables (列出 sys.tables)</option>
                <option value="findTablesLike">findTablesLike (帶參數)</option>
            </select>
            <label for="qParam">參數 p0</label>
            <input type="text" id="qParam" placeholder="例如 user" />
            <button type="button" id="qRun">執行</button>
            <span class="status" id="status">就緒</span>
        </div>

        <div id="err" class="err" style="display:none;"></div>
        <div class="panel">
            <table class="rows" id="rowsTable">
                <thead><tr><th>(尚未執行查詢)</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <script>
        const qSelect = document.getElementById('qSelect');
        const qParam  = document.getElementById('qParam');
        const qRun    = document.getElementById('qRun');
        const statusEl = document.getElementById('status');
        const errEl   = document.getElementById('err');
        const tbl     = document.getElementById('rowsTable');

        async function run() {
            errEl.style.display = 'none';
            statusEl.textContent = '查詢中...';
            qRun.disabled = true;
            try {
                let url = 'DbDemo.aspx?op=rows&q=' + encodeURIComponent(qSelect.value);
                const p = qParam.value.trim();
                if (p) url += '&p0=' + encodeURIComponent(p);
                const res = await fetch(url, { cache: 'no-store' });
                const data = await res.json();
                if (!data.ok) {
                    showError(data.error || ('HTTP ' + res.status));
                    statusEl.textContent = '失敗';
                    return;
                }
                renderRows(data.rows);
                statusEl.textContent = '回傳 ' + data.rows.length + ' 筆';
            } catch (e) {
                showError(e.message);
                statusEl.textContent = '失敗';
            } finally {
                qRun.disabled = false;
            }
        }

        function showError(msg) {
            errEl.textContent = '錯誤: ' + msg;
            errEl.style.display = '';
        }

        function renderRows(rows) {
            const thead = tbl.tHead;
            const tbody = tbl.tBodies[0];
            thead.innerHTML = '';
            tbody.innerHTML = '';
            if (!rows || rows.length === 0) {
                const tr = document.createElement('tr');
                const th = document.createElement('th');
                th.textContent = '(沒有資料)';
                tr.appendChild(th);
                thead.appendChild(tr);
                return;
            }
            const cols = Object.keys(rows[0]);
            const trh = document.createElement('tr');
            cols.forEach(c => {
                const th = document.createElement('th');
                th.textContent = c;
                trh.appendChild(th);
            });
            thead.appendChild(trh);
            rows.forEach(r => {
                const tr = document.createElement('tr');
                cols.forEach(c => {
                    const td = document.createElement('td');
                    const v = r[c];
                    if (v === null || v === undefined) {
                        td.innerHTML = '<span class="null">null</span>';
                    } else if (typeof v === 'object') {
                        td.textContent = JSON.stringify(v);
                    } else {
                        td.textContent = String(v);
                    }
                    tr.appendChild(td);
                });
                tbody.appendChild(tr);
            });
        }

        qRun.addEventListener('click', run);
        qParam.addEventListener('keydown', e => { if (e.key === 'Enter') run(); });
    </script>
</body>
</html>
