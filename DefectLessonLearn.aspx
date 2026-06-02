<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DefectLessonLearn.aspx.cs" Inherits="DefectLessonLearn" ResponseEncoding="utf-8" CodePage="65001" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script>
        // FOUC prevention
        (function () {
            try {
                var t = localStorage.getItem('defect-lesson-theme');
                if (t !== 'light' && t !== 'dark') {
                    t = window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
                }
                document.documentElement.setAttribute('data-theme', t);
            } catch (e) { document.documentElement.setAttribute('data-theme', 'dark'); }
        })();
    </script>
    <title>Defect Case Lesson Learn</title>
    <style>
        :root, [data-theme="dark"] {
            --bg: #0b1220;
            --bg-gradient: radial-gradient(1200px 600px at 20% 0%, #152a52 0%, #0b1220 60%);
            --panel: #0f1b33;
            --panel-elevated: #14233f;
            --text: #e7eefc;
            --muted: #a9b7d6;
            --border: rgba(255,255,255,0.12);
            --row-hover: rgba(99,179,237,0.10);
            --chip: rgba(99,179,237,0.18);
            --chip-active-bg: rgba(99,179,237,0.22);
            --chip-active-border: rgba(99,179,237,0.55);
            --accent: #63b3ed;
            --accent-strong: #2563eb;
            --tint-low: rgba(255,255,255,0.03);
            --tint-med: rgba(255,255,255,0.06);
            --tint-high: rgba(255,255,255,0.10);
            --input-bg: rgba(5,10,20,0.30);
            --warn: #fbbf24;
            --warn-bg: rgba(251,191,36,0.10);
            --warn-border: rgba(251,191,36,0.40);
            --danger: #fca5a5;
            --link: #6cb6ff;
        }
        [data-theme="light"] {
            --bg: #f4f6fb;
            --bg-gradient: radial-gradient(1200px 600px at 20% 0%, #e8efff 0%, #f4f6fb 60%);
            --panel: #ffffff;
            --panel-elevated: #fafbfd;
            --text: #1a2542;
            --muted: #5a6b8c;
            --border: rgba(0,0,0,0.10);
            --row-hover: rgba(59,130,246,0.08);
            --chip: rgba(59,130,246,0.10);
            --chip-active-bg: rgba(59,130,246,0.18);
            --chip-active-border: rgba(59,130,246,0.50);
            --accent: #2563eb;
            --accent-strong: #1d4ed8;
            --tint-low: rgba(0,0,0,0.02);
            --tint-med: rgba(0,0,0,0.04);
            --tint-high: rgba(0,0,0,0.08);
            --input-bg: rgba(255,255,255,0.80);
            --warn: #b45309;
            --warn-bg: #fffbeb;
            --warn-border: #f59e0b;
            --danger: #b91c1c;
            --link: #1d4ed8;
        }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans TC", Arial, sans-serif;
            background: var(--bg-gradient);
            color: var(--text);
            min-height: 100vh;
            transition: background .3s, color .3s;
        }
        .container { max-width: 100%; padding: 16px 20px; }
        .header {
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
            margin-bottom: 14px;
        }
        h1 { font-size: 20px; font-weight: 800; margin: 0; }
        .subtitle { color: var(--muted); font-size: 12px; margin-left: 4px; }
        .toolbar {
            margin-left: auto;
            display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
        }
        .search {
            flex: 1; min-width: 240px;
            padding: 8px 12px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: var(--panel-elevated);
            color: var(--text);
            font-size: 13px;
            outline: none;
        }
        .search:focus { border-color: var(--accent); }
        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 14px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: var(--chip);
            color: var(--text);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background .15s, border-color .15s;
        }
        .btn:hover { background: var(--chip-active-bg); border-color: var(--chip-active-border); }
        .btn-primary {
            background: var(--accent);
            color: white;
            border-color: var(--accent-strong);
        }
        .btn-primary:hover { background: var(--accent-strong); }
        .btn-danger {
            color: var(--danger);
            border-color: var(--warn-border);
        }
        .status-pill {
            font-size: 12px;
            color: var(--muted);
            padding: 4px 10px;
            border-radius: 999px;
            background: var(--tint-low);
        }
        .status-pill.dirty { color: var(--warn); background: var(--warn-bg); border: 1px solid var(--warn-border); }
        .status-pill.saved { color: #34d399; }
        .status-pill.error { color: var(--danger); background: var(--warn-bg); border: 1px solid var(--warn-border); }

        .table-wrap {
            border: 1px solid var(--border);
            border-radius: 12px;
            background: var(--panel);
            overflow: auto;
            max-height: calc(100vh - 140px);
        }
        table.cases {
            border-collapse: collapse;
            width: 100%;
            font-size: 12px;
        }
        table.cases th, table.cases td {
            border: 1px solid var(--border);
            padding: 6px 8px;
            vertical-align: top;
            text-align: left;
        }
        table.cases thead th {
            position: sticky; top: 0;
            background: var(--tint-med);
            color: var(--text);
            font-weight: 800;
            font-size: 12px;
            letter-spacing: .02em;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            z-index: 2;
        }
        table.cases tbody tr:hover td { background: var(--row-hover); }
        table.cases tbody td {
            background: transparent;
        }
        td.img-cell {
            width: 110px;
            min-width: 110px;
            text-align: center;
            position: relative;
        }
        td.img-cell img {
            max-width: 100px; max-height: 120px;
            border-radius: 6px;
            border: 1px solid var(--border);
            cursor: zoom-in;
        }
        td.img-cell.pasting {
            outline: 2px dashed var(--accent);
            outline-offset: -2px;
            background: var(--row-hover);
        }
        td.img-cell .img-actions {
            display: flex; flex-direction: column; gap: 4px;
            align-items: stretch;
            width: 100px;
            margin: 0 auto;
        }
        td.img-cell .img-actions .mini-btn {
            font-size: 11px;
            padding: 4px 6px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--tint-low);
            color: var(--text);
            cursor: pointer;
        }
        td.img-cell .img-actions .mini-btn:hover {
            background: var(--chip);
            border-color: var(--accent);
            color: var(--text);
        }
        td.img-cell .img-replace {
            position: absolute;
            top: 4px; right: 4px;
            display: none;
            gap: 2px;
        }
        td.img-cell:hover .img-replace { display: flex; }
        td.img-cell .img-replace .mini-btn {
            font-size: 10px;
            padding: 2px 6px;
            background: var(--panel-elevated);
            border: 1px solid var(--border);
            border-radius: 4px;
            cursor: pointer;
            color: var(--text);
            opacity: 0.9;
        }
        td.img-cell .img-replace .mini-btn:hover { background: var(--accent); color: white; opacity: 1; }
        td.img-cell .paste-hint {
            font-size: 10px;
            color: var(--accent);
            margin-top: 4px;
            font-weight: 700;
        }
        td.actions {
            white-space: nowrap;
            width: 56px;
        }
        td.actions .btn { padding: 4px 8px; font-size: 11px; }
        td .cell-text { white-space: pre-wrap; word-break: break-word; min-height: 18px; }
        td.editable .cell-text { cursor: text; }
        td.editable .cell-text:focus { outline: 2px solid var(--accent); outline-offset: -2px; background: var(--input-bg); }
        td .link {
            color: var(--link);
            text-decoration: underline;
            word-break: break-all;
            display: inline-block;
        }

        /* Image overlay */
        .img-overlay {
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.85);
            z-index: 9999;
            display: flex; align-items: center; justify-content: center;
            cursor: zoom-out;
        }
        .img-overlay img { max-width: 90vw; max-height: 90vh; border-radius: 6px; box-shadow: 0 8px 32px rgba(0,0,0,0.6); }

        /* Theme toggle */
        .theme-toggle {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 12px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: var(--chip);
            color: var(--text);
            font-size: 13px;
            cursor: pointer;
        }
        .theme-toggle:hover { background: var(--chip-active-bg); border-color: var(--chip-active-border); }
        [data-theme="dark"] .theme-toggle-icon::before { content: '\263C'; }
        [data-theme="light"] .theme-toggle-icon::before { content: '\263D'; }
        [data-theme="dark"] .theme-toggle-label::before { content: 'Light'; }
        [data-theme="light"] .theme-toggle-label::before { content: 'Dark'; }

        .col-img { min-width: 110px; }
        .col-date { min-width: 100px; }
        .col-cat { min-width: 140px; }
        .col-link { min-width: 90px; }
        .col-parts { min-width: 110px; }
        .col-root { min-width: 240px; max-width: 360px; }
        .col-entity { min-width: 150px; }
        .col-eqp { min-width: 130px; }
        .col-impact { min-width: 110px; }
        .col-gen { min-width: 100px; }
        .col-model { min-width: 110px; }
        .col-defect { min-width: 120px; }
        .col-map { min-width: 70px; }
        .col-edx { min-width: 70px; }
        .col-trend { min-width: 110px; }
        .col-pos { min-width: 100px; }
        .col-other { min-width: 130px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Defect Case Lesson Learn</h1>
            <span class="subtitle">內嵌 base64 圖片 + 可編輯/搜尋 / 自動寫回 JSON</span>
            <div class="toolbar">
                <input type="search" id="searchInput" class="search" placeholder="搜尋任一欄位文字..." />
                <button type="button" id="btnAdd" class="btn btn-primary">+ 新增 Case</button>
                <button type="button" id="btnSave" class="btn">儲存</button>
                <button type="button" id="themeToggle" class="theme-toggle" title="切換深色 / 淺色">
                    <span class="theme-toggle-icon"></span>
                    <span class="theme-toggle-label"></span>
                </button>
                <span id="statusPill" class="status-pill">載入中...</span>
            </div>
        </div>

        <div class="table-wrap">
            <table class="cases" id="tbl">
                <thead>
                    <tr>
                        <th class="col-img">Wafer map</th>
                        <th class="col-img">Image</th>
                        <th class="col-date">時間</th>
                        <th class="col-cat">異常類別</th>
                        <th class="col-link">Link</th>
                        <th class="col-parts">異常 parts</th>
                        <th class="col-root">Root cause &amp; Action</th>
                        <th class="col-entity">Entity / Recipe</th>
                        <th class="col-eqp">異常機台</th>
                        <th class="col-impact">Impact / 報廢</th>
                        <th class="col-gen">Generation</th>
                        <th class="col-model">產品型號</th>
                        <th class="col-defect">Defect type</th>
                        <th class="col-map">Map</th>
                        <th class="col-edx">EDX</th>
                        <th class="col-trend">Wafer Trend</th>
                        <th class="col-pos">對應位置</th>
                        <th class="col-other">其他特徵</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="tbody"></tbody>
            </table>
        </div>
    </div>

    <input type="file" id="hiddenFile" accept="image/*" style="display:none;" />

    <script>
        const COLUMNS = [
            { key: 'waferMap', kind: 'img' },
            { key: 'image', kind: 'img' },
            { key: 'date' },
            { key: 'category' },
            { key: 'link', kind: 'link' },
            { key: 'parts' },
            { key: 'rootCause' },
            { key: 'entityRecipe' },
            { key: 'equipment' },
            { key: 'impact' },
            { key: 'generation' },
            { key: 'productModel' },
            { key: 'defectType' },
            { key: 'map' },
            { key: 'edx' },
            { key: 'waferTrend' },
            { key: 'position' },
            { key: 'other' }
        ];

        const state = {
            cases: [],
            dirty: false,
            pendingImageCell: null
        };

        const $ = (sel) => document.querySelector(sel);
        const tbody = $('#tbody');
        const statusPill = $('#statusPill');
        const searchInput = $('#searchInput');
        const hiddenFile = $('#hiddenFile');

        function setStatus(text, cls) {
            statusPill.className = 'status-pill ' + (cls || '');
            statusPill.textContent = text;
        }
        function markDirty() {
            state.dirty = true;
            setStatus('有未儲存變更', 'dirty');
        }
        function markSaved() {
            state.dirty = false;
            setStatus('已儲存 ' + new Date().toLocaleTimeString(), 'saved');
        }

        function uid() {
            return 'case-' + Date.now() + '-' + Math.random().toString(36).slice(2, 6);
        }

        function escapeHtml(s) {
            if (s == null) return '';
            return String(s)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function renderRow(c) {
            const tr = document.createElement('tr');
            tr.setAttribute('data-id', c.id);

            COLUMNS.forEach((col, idx) => {
                const td = document.createElement('td');
                if (col.kind === 'img') {
                    td.className = 'img-cell';
                    const v = c[col.key] || '';
                    if (v) {
                        td.innerHTML =
                            '<img alt="' + col.key + '" src="' + v + '"/>' +
                            '<div class="img-replace">' +
                                '<button type="button" class="mini-btn" data-act="replace">更換</button>' +
                                '<button type="button" class="mini-btn" data-act="remove">移除</button>' +
                            '</div>';
                    } else {
                        td.innerHTML =
                            '<div class="img-actions">' +
                                '<button type="button" class="mini-btn" data-act="upload">📁 選檔</button>' +
                                '<button type="button" class="mini-btn" data-act="paste">📋 貼上</button>' +
                                '<div style="font-size:10px; color:var(--muted); margin-top:2px;">' + col.key + '</div>' +
                            '</div>';
                    }
                    td.addEventListener('click', (ev) => {
                        // Click on image -> overlay viewer
                        if (ev.target.tagName === 'IMG') {
                            openOverlay(ev.target.src);
                            return;
                        }
                        const btn = ev.target.closest && ev.target.closest('[data-act]');
                        if (!btn) return;
                        const act = btn.getAttribute('data-act');
                        if (act === 'upload' || act === 'replace') {
                            state.pendingImageCell = { id: c.id, key: col.key, td: td };
                            clearPasteHighlight();
                            hiddenFile.value = '';
                            hiddenFile.click();
                        } else if (act === 'paste') {
                            state.pendingImageCell = { id: c.id, key: col.key, td: td };
                            setPasteHighlight(td);
                            setStatus('已選定 ' + col.key + ' 欄,請按 Ctrl+V 貼上剪貼簿的圖片', 'dirty');
                        } else if (act === 'remove') {
                            c[col.key] = '';
                            markDirty();
                            const newTr = renderRow(c);
                            tr.replaceWith(newTr);
                        }
                    });
                } else if (col.kind === 'link') {
                    td.className = 'editable';
                    const v = c[col.key] || '';
                    if (v) {
                        td.innerHTML = '<a class="link" target="_blank" rel="noopener noreferrer" href="' + escapeHtml(v) + '">' + escapeHtml(v) + '</a>';
                    } else {
                        td.innerHTML = '<div class="cell-text" contenteditable="true" data-key="' + col.key + '"></div>';
                    }
                    td.addEventListener('dblclick', () => {
                        td.innerHTML = '<div class="cell-text" contenteditable="true" data-key="' + col.key + '">' + escapeHtml(v) + '</div>';
                        const ce = td.querySelector('.cell-text');
                        ce.focus();
                        wireEditable(ce, c);
                    });
                } else {
                    td.className = 'editable';
                    const v = c[col.key] || '';
                    td.innerHTML = '<div class="cell-text" contenteditable="true" data-key="' + col.key + '">' + escapeHtml(v) + '</div>';
                }

                if (td.querySelector('.cell-text[contenteditable]')) {
                    wireEditable(td.querySelector('.cell-text[contenteditable]'), c);
                }

                tr.appendChild(td);
            });

            // actions cell
            const tdAct = document.createElement('td');
            tdAct.className = 'actions';
            tdAct.innerHTML = '<button type="button" class="btn btn-danger" data-act="del">刪除</button>';
            tdAct.querySelector('button').addEventListener('click', () => {
                if (!confirm('確定刪除這筆 case?')) return;
                state.cases = state.cases.filter(x => x.id !== c.id);
                tr.remove();
                markDirty();
            });
            tr.appendChild(tdAct);
            return tr;
        }

        function wireEditable(ce, c) {
            ce.addEventListener('blur', () => {
                const key = ce.getAttribute('data-key');
                const newVal = ce.textContent;
                if (c[key] !== newVal) {
                    c[key] = newVal;
                    markDirty();
                    if (key === 'link') {
                        // rebuild row to show link
                        const tr = ce.closest('tr');
                        if (tr) {
                            const newTr = renderRow(c);
                            tr.replaceWith(newTr);
                        }
                    }
                }
            });
        }

        function renderAll() {
            tbody.innerHTML = '';
            const q = (searchInput.value || '').trim().toLowerCase();
            const fragments = document.createDocumentFragment();
            state.cases.forEach(c => {
                if (q && !matchSearch(c, q)) return;
                fragments.appendChild(renderRow(c));
            });
            tbody.appendChild(fragments);
        }

        function matchSearch(c, q) {
            for (const col of COLUMNS) {
                if (col.kind === 'img') continue;
                const v = c[col.key];
                if (v && String(v).toLowerCase().indexOf(q) >= 0) return true;
            }
            return false;
        }

        // ---- Image upload (file -> base64) ----
        function applyImageDataUrl(dataUrl) {
            const ctx = state.pendingImageCell;
            if (!ctx) return false;
            const c = state.cases.find(x => x.id === ctx.id);
            if (!c) return false;
            c[ctx.key] = dataUrl;
            const tr = ctx.td.closest('tr');
            if (tr) {
                const newTr = renderRow(c);
                tr.replaceWith(newTr);
            }
            state.pendingImageCell = null;
            clearPasteHighlight();
            markDirty();
            return true;
        }

        hiddenFile.addEventListener('change', () => {
            const f = hiddenFile.files && hiddenFile.files[0];
            if (!f) return;
            const reader = new FileReader();
            reader.onload = () => { applyImageDataUrl(reader.result); };
            reader.readAsDataURL(f);
        });

        function setPasteHighlight(td) {
            clearPasteHighlight();
            td.classList.add('pasting');
        }
        function clearPasteHighlight() {
            document.querySelectorAll('td.img-cell.pasting').forEach(el => el.classList.remove('pasting'));
        }

        // ---- Clipboard paste (image only) ----
        document.addEventListener('paste', (ev) => {
            if (!state.pendingImageCell) return;
            const items = (ev.clipboardData && ev.clipboardData.items) || [];
            for (const it of items) {
                if (it.kind === 'file' && it.type && it.type.indexOf('image/') === 0) {
                    const blob = it.getAsFile();
                    if (!blob) continue;
                    ev.preventDefault();
                    const reader = new FileReader();
                    reader.onload = () => { applyImageDataUrl(reader.result); };
                    reader.readAsDataURL(blob);
                    return;
                }
            }
        });

        // Click outside any image cell clears the paste target
        document.addEventListener('click', (ev) => {
            if (!state.pendingImageCell) return;
            const cell = ev.target.closest && ev.target.closest('td.img-cell');
            if (cell !== state.pendingImageCell.td) {
                state.pendingImageCell = null;
                clearPasteHighlight();
            }
        }, true);

        // ---- Overlay ----
        let overlay = null;
        function openOverlay(src) {
            closeOverlay();
            overlay = document.createElement('div');
            overlay.className = 'img-overlay';
            const img = document.createElement('img');
            img.src = src;
            overlay.appendChild(img);
            overlay.addEventListener('click', closeOverlay);
            document.body.appendChild(overlay);
        }
        function closeOverlay() {
            if (overlay && overlay.parentNode) overlay.parentNode.removeChild(overlay);
            overlay = null;
        }
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape') {
                closeOverlay();
                if (state.pendingImageCell) {
                    state.pendingImageCell = null;
                    clearPasteHighlight();
                    setStatus('已取消貼上');
                }
            }
        });

        // ---- Theme ----
        $('#themeToggle').addEventListener('click', () => {
            const cur = document.documentElement.getAttribute('data-theme') || 'dark';
            const next = cur === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', next);
            try { localStorage.setItem('defect-lesson-theme', next); } catch (e) {}
        });

        // ---- Search ----
        searchInput.addEventListener('input', renderAll);

        // ---- Add ----
        $('#btnAdd').addEventListener('click', () => {
            const c = { id: uid() };
            COLUMNS.forEach(col => { c[col.key] = ''; });
            state.cases.unshift(c);
            renderAll();
            markDirty();
        });

        // ---- Save ----
        $('#btnSave').addEventListener('click', save);
        async function save() {
            setStatus('儲存中...');
            try {
                const res = await fetch('DefectLessonLearn.aspx?op=save', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify({ cases: state.cases })
                });
                const data = await res.json();
                if (data.ok) markSaved();
                else setStatus('儲存失敗: ' + (data.error || 'unknown'), 'error');
            } catch (e) {
                setStatus('儲存失敗: ' + e.message, 'error');
            }
        }

        window.addEventListener('beforeunload', (e) => {
            if (state.dirty) {
                e.preventDefault();
                e.returnValue = '有未儲存的變更,確定要離開?';
                return e.returnValue;
            }
        });

        // ---- Load on start ----
        (async function load() {
            setStatus('載入中...');
            try {
                const res = await fetch('DefectLessonLearn.aspx?op=list', { cache: 'no-store' });
                const data = await res.json();
                state.cases = Array.isArray(data.cases) ? data.cases : [];
                // ensure each has an id
                state.cases.forEach(c => { if (!c.id) c.id = uid(); });
                renderAll();
                setStatus('共 ' + state.cases.length + ' 筆');
            } catch (e) {
                setStatus('載入失敗: ' + e.message, 'error');
            }
        })();
    </script>
</body>
</html>
