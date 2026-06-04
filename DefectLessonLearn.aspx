<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DefectLessonLearn.aspx.cs" Inherits="DefectLessonLearn" ResponseEncoding="utf-8" %>

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
            /* Solid background — semi-transparent tint over scrolling rows
               would show row text through the header. Use --panel-elevated
               so the header stays opaque while still looking like a header. */
            background: var(--panel-elevated);
            color: var(--text);
            font-weight: 800;
            font-size: 12px;
            letter-spacing: .02em;
            white-space: nowrap;
            z-index: 3;
            padding: 6px 8px;
            text-align: center;     /* center plain-text headers (Wafer map, Image, etc.) */
            box-shadow: 0 1px 0 var(--border);
        }
        table.cases thead th[data-col] {
            padding: 0;             /* sortable headers use their own inner padding */
        }
        table.cases thead th[data-col] .th-inner {
            display: flex;
            align-items: center;
            justify-content: center; /* center the label + icons */
            gap: 4px;
            padding: 6px 8px;
            cursor: pointer;
            user-select: none;
            overflow: hidden;
        }
        table.cases thead th[data-col] .th-label {
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            text-align: center;
        }
        table.cases thead th[data-col] .th-sort {
            font-size: 9px; opacity: 0.35;
            line-height: 1;
        }
        table.cases thead th[data-col].sort-asc .th-sort,
        table.cases thead th[data-col].sort-desc .th-sort {
            opacity: 1;
            color: var(--accent);
        }
        table.cases thead th[data-col] .th-filter {
            border: 1px solid var(--border);
            border-radius: 4px;
            background: transparent;
            color: var(--muted);
            font-size: 11px;
            line-height: 1;
            padding: 1px 4px;
            cursor: pointer;
        }
        table.cases thead th[data-col] .th-filter:hover {
            background: var(--chip);
            color: var(--text);
        }
        table.cases thead th[data-col].filtered .th-filter {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }

        /* Filter popover */
        .filter-pop {
            position: absolute;
            z-index: 9000;
            background: var(--panel-elevated);
            border: 1px solid var(--border);
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.25);
            padding: 8px;
            width: 260px;
            font-size: 12px;
            color: var(--text);
        }
        .filter-pop input.filter-search {
            width: 100%;
            box-sizing: border-box;
            padding: 6px 8px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--input-bg);
            color: var(--text);
            font-size: 12px;
            margin-bottom: 6px;
            outline: none;
        }
        .filter-pop input.filter-search:focus { border-color: var(--accent); }
        .filter-pop .filter-list {
            max-height: 220px;
            overflow-y: auto;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--panel);
        }
        .filter-pop .filter-item {
            display: flex; align-items: center; gap: 6px;
            padding: 4px 8px;
            cursor: pointer;
            border-bottom: 1px solid var(--tint-low);
        }
        .filter-pop .filter-item:last-child { border-bottom: none; }
        .filter-pop .filter-item:hover { background: var(--row-hover); }
        .filter-pop .filter-item input[type="checkbox"] { margin: 0; }
        .filter-pop .filter-item .filter-label {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .filter-pop .filter-item .filter-count {
            color: var(--muted);
            font-size: 10px;
            font-weight: 600;
        }
        .filter-pop .filter-empty {
            color: var(--muted);
            text-align: center;
            padding: 14px;
            font-style: italic;
        }
        .filter-pop .filter-toolbar {
            display: flex; gap: 6px;
            margin: 6px 0 0 0;
        }
        .filter-pop .filter-toolbar .ftb {
            font-size: 11px;
            padding: 4px 8px;
            border: 1px solid var(--border);
            border-radius: 4px;
            background: var(--tint-low);
            color: var(--text);
            cursor: pointer;
            flex: 1;
        }
        .filter-pop .filter-toolbar .ftb:hover { background: var(--chip); border-color: var(--accent); }
        .filter-pop .filter-toolbar .ftb.primary { background: var(--accent); color: white; border-color: var(--accent); }
        .filter-pop .filter-toolbar .ftb.primary:hover { background: var(--accent-strong); }

        table.cases tbody tr:hover td { background: var(--row-hover); }
        table.cases tbody td {
            background: transparent;
        }
        td.img-cell {
            min-width: 190px;
            width: 190px;
            text-align: center;
            position: relative;
            cursor: pointer;
        }
        td.img-cell.pasting {
            outline: 2px dashed var(--accent);
            outline-offset: -2px;
            background: var(--row-hover);
        }
        td.img-cell.drop-target {
            outline: 2px solid var(--accent);
            outline-offset: -2px;
            background: var(--chip-active-bg);
        }
        td.img-cell .img-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            justify-content: center;
            margin: 0 auto 4px auto;
            max-width: 180px;
        }
        td.img-cell .img-thumb {
            position: relative;
            display: inline-block;
            line-height: 0;
            flex: 0 0 80px;     /* don't shrink — every thumb stays this size */
            width: 80px;
            height: 80px;
        }
        td.img-cell .img-thumb img {
            width: 80px; height: 80px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid var(--border);
            cursor: zoom-in;
            display: block;
        }
        td.img-cell .img-thumb .thumb-x {
            position: absolute;
            top: -6px; right: -6px;
            width: 18px; height: 18px;
            border-radius: 50%;
            background: var(--danger, #ef4444);
            color: white;
            border: 1px solid var(--panel);
            font-size: 11px;
            font-weight: 700;
            line-height: 15px;
            padding: 0;
            cursor: pointer;
            opacity: 0;
            transition: opacity .12s;
        }
        td.img-cell .img-thumb:hover .thumb-x { opacity: 1; }
        td.img-cell .img-empty {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 80px;
            font-size: 11px;
            color: var(--muted);
            border: 1px dashed var(--border);
            border-radius: 6px;
            margin: 6px;
            user-select: none;
        }
        td.img-cell .img-empty .img-empty-icon { font-size: 18px; margin-bottom: 2px; }
        td.img-cell.pasting .img-empty,
        td.img-cell:hover .img-empty {
            color: var(--text);
            border-color: var(--accent);
        }
        td.img-cell .img-clear {
            display: inline-block;
            font-size: 10px;
            color: var(--muted);
            padding: 2px 6px;
            border: 1px solid var(--border);
            border-radius: 4px;
            background: var(--tint-low);
            cursor: pointer;
        }
        td.img-cell .img-clear:hover {
            color: var(--danger, #ef4444);
            border-color: var(--danger, #ef4444);
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
        /* contenteditable placeholder for empty cells */
        td .cell-text[data-placeholder]:empty::before {
            content: attr(data-placeholder);
            color: var(--muted);
            opacity: 0.55;
            font-style: italic;
        }
        td.link-cell {
            text-align: center;
            white-space: nowrap;
            min-width: 110px;
        }
        td.link-cell .link-row {
            display: inline-grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 4px;
            vertical-align: middle;
            max-width: calc(100% - 30px);
            min-width: 80px;
        }
        td.link-cell .link-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 28px; height: 26px;
            padding: 0 4px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            line-height: 1;
            background: var(--chip);
            border: 1px solid var(--border);
            transition: background .15s, border-color .15s;
            color: var(--text);
        }
        td.link-cell .link-icon:hover {
            background: var(--chip-active-bg);
            border-color: var(--chip-active-border);
        }
        td.link-cell .link-emoji { font-size: 13px; }
        td.link-cell .link-idx {
            margin-left: 3px;
            font-size: 10px;
            font-weight: 700;
            color: var(--muted);
        }
        td.link-cell .mini-btn {
            margin-left: 4px;
            font-size: 11px;
            padding: 2px 6px;
            border: 1px solid var(--border);
            border-radius: 4px;
            background: var(--tint-low);
            color: var(--text);
            cursor: pointer;
            vertical-align: middle;
        }
        td.link-cell .mini-btn:hover {
            background: var(--chip);
            border-color: var(--accent);
        }
        td.link-cell .link-placeholder {
            display: inline-block;
            font-size: 11px;
            color: var(--muted);
            opacity: 0.55;
            font-style: italic;
            vertical-align: middle;
        }

        /* Link editor popover (reuses .filter-pop layout but with a textarea) */
        .link-editor .link-textarea {
            width: 100%;
            box-sizing: border-box;
            padding: 8px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--input-bg);
            color: var(--text);
            font-family: monospace;
            font-size: 12px;
            resize: vertical;
            outline: none;
        }
        .link-editor .link-textarea:focus { border-color: var(--accent); }

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
        .usage-hint {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            margin-bottom: 10px;
            border: 1px solid var(--border);
            border-left: 4px solid var(--accent);
            border-radius: 8px;
            background: var(--panel-elevated);
            color: var(--text);
            font-size: 12px;
        }
        .usage-hint.collapsed { display: none; }
        .usage-content {
            flex: 1;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 14px 18px;
        }
        .usage-tag {
            font-weight: 800;
            color: var(--accent);
        }
        .usage-item b { color: var(--text); }
        .usage-hint kbd {
            display: inline-block;
            padding: 1px 6px;
            font-family: inherit;
            font-size: 11px;
            color: var(--text);
            background: var(--tint-med);
            border: 1px solid var(--border);
            border-radius: 4px;
            box-shadow: 0 1px 0 var(--border);
        }
        .usage-close {
            font-size: 16px;
            line-height: 1;
            background: transparent;
            border: none;
            color: var(--muted);
            cursor: pointer;
            padding: 4px 8px;
            border-radius: 4px;
        }
        .usage-close:hover { background: var(--tint-med); color: var(--text); }
        .btn-help {
            font-size: 13px;
            padding: 6px 10px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: var(--chip);
            color: var(--text);
            cursor: pointer;
        }
        .btn-help:hover { background: var(--chip-active-bg); border-color: var(--chip-active-border); }

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

        .col-img { min-width: 190px; }
        .col-date { min-width: 100px; }
        .col-cat { min-width: 140px; }
        .col-link { min-width: 110px; }
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
                <button type="button" id="btnClearFilters" class="btn" title="清除所有排序與篩選">↻ 清除篩選</button>
                <button type="button" id="btnSave" class="btn">儲存</button>
                <button type="button" id="btnHelp" class="btn-help" title="顯示操作提示" style="display:none;">?</button>
                <button type="button" id="themeToggle" class="theme-toggle" title="切換深色 / 淺色">
                    <span class="theme-toggle-icon"></span>
                    <span class="theme-toggle-label"></span>
                </button>
                <span id="statusPill" class="status-pill">載入中...</span>
            </div>
        </div>

        <div class="usage-hint" id="usageHint">
            <div class="usage-content">
                <span class="usage-tag">💡 操作提示</span>
                <span class="usage-item"><b>圖片</b>:點該格 → <kbd>Ctrl</kbd>+<kbd>V</kbd> 貼上(可連續貼多張),或直接拖檔到該格</span>
                <span class="usage-item"><b>連結</b>:點 <kbd>✎</kbd> 編輯,每行一個 URL</span>
                <span class="usage-item"><b>排序</b>:點欄位標題(▲ 升 / ▼ 降 / 再點取消)</span>
                <span class="usage-item"><b>篩選</b>:點欄位標題旁 <kbd>▾</kbd>,下拉多選 + 文字搜尋</span>
                <span class="usage-item"><b>文字</b>:點該格直接編輯</span>
            </div>
            <button type="button" class="usage-close" id="usageClose" title="關閉提示">×</button>
        </div>

        <div class="table-wrap">
            <table class="cases" id="tbl">
                <thead>
                    <tr id="theadRow">
                        <th class="col-img">Wafer map</th>
                        <th class="col-img">Image</th>
                        <th class="col-date" data-col="date">時間</th>
                        <th class="col-cat" data-col="category">異常類別</th>
                        <th class="col-link" data-col="link">Link</th>
                        <th class="col-parts" data-col="parts">異常 parts</th>
                        <th class="col-root" data-col="rootCause">Root cause &amp; Action</th>
                        <th class="col-entity" data-col="entityRecipe">Entity / Recipe</th>
                        <th class="col-eqp" data-col="equipment">異常機台</th>
                        <th class="col-impact" data-col="impact">Impact / 報廢</th>
                        <th class="col-gen" data-col="generation">Generation</th>
                        <th class="col-model" data-col="productModel">產品型號</th>
                        <th class="col-defect" data-col="defectType">Defect type</th>
                        <th class="col-map" data-col="map">Map</th>
                        <th class="col-edx" data-col="edx">EDX</th>
                        <th class="col-trend" data-col="waferTrend">Wafer Trend</th>
                        <th class="col-pos" data-col="position">對應位置</th>
                        <th class="col-other" data-col="other">其他特徵</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="tbody"></tbody>
            </table>
        </div>
    </div>


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
            pendingImageCell: null,
            // Method-B concurrency tracking:
            //  - dirtyIds:   ids of cases modified or just created (need server upsert)
            //  - deletedIds: ids removed from the table that EXIST on the server (need server delete)
            //  - loadedIds:  ids that came from the last server load (= they're on disk)
            dirtyIds: new Set(),
            deletedIds: new Set(),
            loadedIds: new Set()
        };

        const $ = (sel) => document.querySelector(sel);
        const tbody = $('#tbody');
        const statusPill = $('#statusPill');
        const searchInput = $('#searchInput');

        function setStatus(text, cls) {
            statusPill.className = 'status-pill ' + (cls || '');
            statusPill.textContent = text;
        }
        function markDirty(id) {
            state.dirty = true;
            if (id) state.dirtyIds.add(id);
            const n = state.dirtyIds.size + state.deletedIds.size;
            setStatus(n > 0 ? ('有 ' + n + ' 筆未儲存') : '有未儲存變更', 'dirty');
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

        // Add https:// if the user pasted something without a scheme
        // (so "p58esigp01/foo" still resolves to an absolute external link)
        function normalizeUrl(raw) {
            const s = String(raw || '').trim();
            if (!s) return '';
            if (/^[a-z][a-z0-9+.-]*:/i.test(s)) return s;       // already has scheme
            if (s.startsWith('//')) return 'https:' + s;
            return 'https://' + s;
        }

        // Parse a link field (newline-separated or array) into a clean array of URLs.
        function parseLinks(raw) {
            if (Array.isArray(raw)) {
                return raw.map(s => String(s || '').trim()).filter(s => s.length > 0);
            }
            return String(raw || '')
                .split(/[\r\n]+/)
                .map(s => s.trim())
                .filter(s => s.length > 0);
        }
        function joinLinks(arr) {
            return (arr || []).map(s => String(s || '').trim()).filter(Boolean).join('\n');
        }

        // Parse an image field (array of data URLs, or legacy single string) into an array.
        function parseImages(raw) {
            if (Array.isArray(raw)) return raw.filter(s => typeof s === 'string' && s.length > 0);
            if (typeof raw === 'string' && raw.length > 0) return [raw];
            return [];
        }

        function renderRow(c) {
            const tr = document.createElement('tr');
            tr.setAttribute('data-id', c.id);

            COLUMNS.forEach((col, idx) => {
                const td = document.createElement('td');
                if (col.kind === 'img') {
                    td.className = 'img-cell';
                    const imgs = parseImages(c[col.key]);
                    let html = '';
                    if (imgs.length > 0) {
                        html += '<div class="img-grid">' + imgs.map((src, i) =>
                            '<div class="img-thumb">' +
                                '<img alt="' + col.key + '" src="' + src + '"/>' +
                                '<button type="button" class="thumb-x" data-act="remove" data-idx="' + i + '" title="移除這張">×</button>' +
                            '</div>'
                        ).join('') + '</div>';
                        if (imgs.length >= 2) {
                            html += '<button type="button" class="img-clear" data-act="remove-all">全清</button>';
                        }
                    } else {
                        html =
                            '<div class="img-empty">' +
                                '<span class="img-empty-icon">📋</span>' +
                                '<span>點此 + Ctrl+V</span>' +
                                '<span style="font-size:10px;opacity:.7;">或拖曳圖檔</span>' +
                            '</div>';
                    }
                    td.innerHTML = html;
                    td.addEventListener('click', (ev) => {
                        // × on a thumb -> remove that one
                        const xBtn = ev.target.closest && ev.target.closest('.thumb-x');
                        if (xBtn) {
                            ev.stopPropagation();
                            const idx = parseInt(xBtn.getAttribute('data-idx'), 10);
                            const arr = parseImages(c[col.key]);
                            arr.splice(idx, 1);
                            c[col.key] = arr;
                            markDirty(c.id);
                            const newTr = renderRow(c);
                            tr.replaceWith(newTr);
                            return;
                        }
                        // Click on a thumb image -> overlay viewer
                        if (ev.target.tagName === 'IMG') {
                            openOverlay(ev.target.src);
                            return;
                        }
                        // Click "全清" button
                        const clearBtn = ev.target.closest && ev.target.closest('[data-act="remove-all"]');
                        if (clearBtn) {
                            ev.stopPropagation();
                            if (!confirm('清掉這格全部圖片?')) return;
                            c[col.key] = [];
                            markDirty(c.id);
                            const newTr = renderRow(c);
                            tr.replaceWith(newTr);
                            return;
                        }
                        // Otherwise: clicking anywhere in the cell activates paste mode
                        state.pendingImageCell = { id: c.id, key: col.key, td: td };
                        setPasteHighlight(td);
                        setStatus('已選定 ' + col.key + ',按 Ctrl+V 貼上 / 拖檔到此 / 按 ESC 取消', 'dirty');
                    });

                    // ---- Drag-and-drop image files ----
                    td.addEventListener('dragover', (ev) => {
                        ev.preventDefault();
                        td.classList.add('drop-target');
                    });
                    td.addEventListener('dragleave', () => {
                        td.classList.remove('drop-target');
                    });
                    td.addEventListener('drop', (ev) => {
                        ev.preventDefault();
                        td.classList.remove('drop-target');
                        const files = Array.from((ev.dataTransfer && ev.dataTransfer.files) || [])
                            .filter(f => f.type && f.type.indexOf('image/') === 0);
                        if (!files.length) return;
                        // Activate this cell as the pending target
                        state.pendingImageCell = { id: c.id, key: col.key, td: td };
                        Promise.all(files.map(f => new Promise(res => {
                            const r = new FileReader();
                            r.onload = () => res(r.result);
                            r.onerror = () => res(null);
                            r.readAsDataURL(f);
                        }))).then(urls => {
                            appendImageDataUrls(urls.filter(Boolean), { keepPasteMode: false });
                            state.pendingImageCell = null;
                            clearPasteHighlight();
                        });
                    });
                } else if (col.kind === 'link') {
                    td.className = 'link-cell';
                    const arr = parseLinks(c[col.key]);
                    if (arr.length > 0) {
                        const iconsHtml = arr.map((u, i) =>
                            '<a class="link-icon" target="_blank" rel="noopener noreferrer" href="' +
                                escapeHtml(normalizeUrl(u)) + '" title="' + escapeHtml(u) + '">' +
                                '<span class="link-emoji">🔗</span>' +
                                (arr.length > 1 ? '<span class="link-idx">' + (i + 1) + '</span>' : '') +
                            '</a>'
                        ).join('');
                        td.innerHTML =
                            '<div class="link-row">' + iconsHtml + '</div>' +
                            '<button type="button" class="mini-btn" data-act="edit-link" title="編輯連結(每行一個)">✎</button>';
                    } else {
                        td.innerHTML = '<div class="cell-text link-placeholder" data-key="' + col.key + '" data-placeholder="點 ✎ 新增連結">&nbsp;</div>' +
                            '<button type="button" class="mini-btn" data-act="edit-link" title="新增連結">+</button>';
                    }
                    td.addEventListener('click', (ev) => {
                        const btn = ev.target.closest && ev.target.closest('[data-act="edit-link"]');
                        if (!btn) return;
                        openLinkEditor(c, col.key, td);
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
                // If this case exists on the server, queue a server-side delete.
                // If it was a never-saved local addition, just drop it locally.
                state.dirtyIds.delete(c.id);
                if (state.loadedIds.has(c.id)) {
                    state.deletedIds.add(c.id);
                }
                state.dirty = true;
                const n = state.dirtyIds.size + state.deletedIds.size;
                setStatus(n > 0 ? ('有 ' + n + ' 筆未儲存') : '有未儲存變更', 'dirty');
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
                    markDirty(c.id);
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

        // ---- Sort + Filter state ----
        // state.sort = { key, dir: 'asc' | 'desc' | null }
        // state.filters[key] = Set<value>  (if absent or empty -> no filter)
        state.sort = { key: null, dir: null };
        state.filters = {};

        function parseDateValue(s) {
            const m = String(s || '').match(/(\d{4})\D+(\d{1,2})(?:\D+(\d{1,2}))?/);
            if (!m) return NaN;
            const y = parseInt(m[1], 10);
            const mo = parseInt(m[2], 10) || 1;
            const d = parseInt(m[3], 10) || 1;
            return new Date(y, mo - 1, d).getTime();
        }
        function sortRows(rows, key, dir) {
            const factor = dir === 'desc' ? -1 : 1;
            const isDateCol = (key === 'date');
            return rows.slice().sort((a, b) => {
                const va = (a[key] == null) ? '' : String(a[key]);
                const vb = (b[key] == null) ? '' : String(b[key]);
                if (isDateCol) {
                    const da = parseDateValue(va);
                    const db = parseDateValue(vb);
                    if (!isNaN(da) && !isNaN(db)) return factor * (da - db);
                }
                const na = parseFloat(va.replace(/[, ]/g, ''));
                const nb = parseFloat(vb.replace(/[, ]/g, ''));
                if (!isNaN(na) && !isNaN(nb) && va.match(/\d/) && vb.match(/\d/)) {
                    if (na !== nb) return factor * (na - nb);
                }
                return factor * va.localeCompare(vb, 'zh-Hant', { numeric: true });
            });
        }
        function filterRows(rows) {
            const keys = Object.keys(state.filters);
            if (keys.length === 0) return rows;
            return rows.filter(c => {
                for (const k of keys) {
                    const set = state.filters[k];
                    if (set && set.size > 0) {
                        if (!set.has(c[k] || '')) return false;
                    }
                }
                return true;
            });
        }
        function getVisibleCases() {
            let rows = state.cases.slice();
            rows = filterRows(rows);
            const q = (searchInput.value || '').trim().toLowerCase();
            if (q) rows = rows.filter(c => matchSearch(c, q));
            if (state.sort.key && state.sort.dir) {
                rows = sortRows(rows, state.sort.key, state.sort.dir);
            }
            return rows;
        }

        function renderAll() {
            tbody.innerHTML = '';
            const fragments = document.createDocumentFragment();
            getVisibleCases().forEach(c => fragments.appendChild(renderRow(c)));
            tbody.appendChild(fragments);
            updateStatusCount();
        }

        function updateStatusCount() {
            const total = state.cases.length;
            const shown = getVisibleCases().length;
            if (shown === total) {
                setStatus('共 ' + total + ' 筆');
            } else {
                setStatus('顯示 ' + shown + ' / ' + total + ' 筆', 'dirty');
            }
        }

        function matchSearch(c, q) {
            for (const col of COLUMNS) {
                if (col.kind === 'img') continue;
                const v = c[col.key];
                if (v && String(v).toLowerCase().indexOf(q) >= 0) return true;
            }
            return false;
        }

        // ---- Decorate <th data-col="..."> with sort indicator + filter button ----
        function decorateHeaders() {
            document.querySelectorAll('#theadRow th[data-col]').forEach(th => {
                const key = th.getAttribute('data-col');
                const label = th.textContent.trim();
                th.innerHTML =
                    '<div class="th-inner">' +
                        '<span class="th-label">' + escapeHtml(label) + '</span>' +
                        '<span class="th-sort">▲▼</span>' +
                        '<button type="button" class="th-filter" data-act="filter" title="篩選">▾</button>' +
                    '</div>';
                // sort click on the inner area (not the filter button)
                th.querySelector('.th-inner').addEventListener('click', (ev) => {
                    if (ev.target.closest('[data-act="filter"]')) return;
                    cycleSort(key, th);
                });
                th.querySelector('[data-act="filter"]').addEventListener('click', (ev) => {
                    ev.stopPropagation();
                    openFilterPopover(key, th);
                });
            });
        }
        function cycleSort(key, th) {
            if (state.sort.key === key) {
                state.sort.dir = state.sort.dir === 'asc' ? 'desc'
                              : state.sort.dir === 'desc' ? null : 'asc';
                if (!state.sort.dir) state.sort.key = null;
            } else {
                state.sort.key = key;
                state.sort.dir = 'asc';
            }
            // update visual on all headers
            document.querySelectorAll('#theadRow th[data-col]').forEach(t => {
                t.classList.remove('sort-asc', 'sort-desc');
                const sortEl = t.querySelector('.th-sort');
                if (sortEl) sortEl.textContent = '▲▼';
            });
            if (state.sort.key) {
                const t = document.querySelector('#theadRow th[data-col="' + state.sort.key + '"]');
                if (t) {
                    t.classList.add(state.sort.dir === 'asc' ? 'sort-asc' : 'sort-desc');
                    const sortEl = t.querySelector('.th-sort');
                    if (sortEl) sortEl.textContent = state.sort.dir === 'asc' ? '▲' : '▼';
                }
            }
            renderAll();
        }

        // ---- Filter popover ----
        let activePopover = null;
        function closeFilterPopover() {
            if (activePopover && activePopover.parentNode) activePopover.parentNode.removeChild(activePopover);
            activePopover = null;
        }
        function openFilterPopover(key, anchor) {
            closeFilterPopover();
            // distinct values, sorted; preserve insertion order with stable sort
            const counts = new Map();
            state.cases.forEach(c => {
                const v = c[key] || '';
                counts.set(v, (counts.get(v) || 0) + 1);
            });
            const values = [...counts.keys()].sort((a, b) => a.localeCompare(b, 'zh-Hant', { numeric: true }));
            const filtSet = state.filters[key]; // may be undefined (= all checked)

            const pop = document.createElement('div');
            pop.className = 'filter-pop';
            const rect = anchor.getBoundingClientRect();
            pop.style.top = (rect.bottom + window.scrollY + 4) + 'px';
            pop.style.left = (rect.left + window.scrollX) + 'px';
            const itemsHtml = values.length === 0
                ? '<div class="filter-empty">無資料</div>'
                : values.map((v, i) => {
                    const checked = (!filtSet || filtSet.has(v));
                    const lbl = v === '' ? '<em style="opacity:.6">(空)</em>' : escapeHtml(v);
                    return '<label class="filter-item">' +
                        '<input type="checkbox" value="' + i + '"' + (checked ? ' checked' : '') + '/>' +
                        '<span class="filter-label" title="' + escapeHtml(v) + '">' + lbl + '</span>' +
                        '<span class="filter-count">' + counts.get(v) + '</span>' +
                        '</label>';
                }).join('');
            pop.innerHTML =
                '<input type="text" class="filter-search" placeholder="搜尋值..." />' +
                '<div class="filter-list">' + itemsHtml + '</div>' +
                '<div class="filter-toolbar">' +
                    '<button type="button" class="ftb" data-act="all">全選</button>' +
                    '<button type="button" class="ftb" data-act="none">清除</button>' +
                    '<button type="button" class="ftb primary" data-act="apply">套用</button>' +
                '</div>';

            document.body.appendChild(pop);
            activePopover = pop;

            const searchEl = pop.querySelector('.filter-search');
            const listEl = pop.querySelector('.filter-list');
            const items = pop.querySelectorAll('.filter-item');

            searchEl.addEventListener('input', () => {
                const q = searchEl.value.trim().toLowerCase();
                items.forEach((it, i) => {
                    const v = values[i];
                    const visible = !q || v.toLowerCase().indexOf(q) >= 0;
                    it.style.display = visible ? '' : 'none';
                });
            });
            searchEl.focus();

            pop.querySelector('[data-act="all"]').addEventListener('click', () => {
                items.forEach(it => {
                    if (it.style.display !== 'none') it.querySelector('input[type=checkbox]').checked = true;
                });
            });
            pop.querySelector('[data-act="none"]').addEventListener('click', () => {
                items.forEach(it => {
                    if (it.style.display !== 'none') it.querySelector('input[type=checkbox]').checked = false;
                });
            });
            pop.querySelector('[data-act="apply"]').addEventListener('click', () => {
                const allChecked = [];
                let anyUnchecked = false;
                items.forEach((it, i) => {
                    if (it.querySelector('input[type=checkbox]').checked) {
                        allChecked.push(values[i]);
                    } else {
                        anyUnchecked = true;
                    }
                });
                if (!anyUnchecked) {
                    delete state.filters[key]; // no filter == all values pass
                } else {
                    state.filters[key] = new Set(allChecked);
                }
                // update header visual
                const th = document.querySelector('#theadRow th[data-col="' + key + '"]');
                if (th) th.classList.toggle('filtered', !!state.filters[key]);
                closeFilterPopover();
                renderAll();
            });
        }

        // ---- Multi-link editor popover ----
        let linkEditorPop = null;
        function closeLinkEditor() {
            if (linkEditorPop && linkEditorPop.parentNode) linkEditorPop.parentNode.removeChild(linkEditorPop);
            linkEditorPop = null;
        }
        function openLinkEditor(c, key, anchor) {
            closeLinkEditor();
            const initial = joinLinks(parseLinks(c[key]));

            const pop = document.createElement('div');
            pop.className = 'filter-pop link-editor';
            const rect = anchor.getBoundingClientRect();
            const top = rect.bottom + window.scrollY + 4;
            // align right edge of popover with right edge of anchor if popover would overflow
            const popWidth = 360;
            let left = rect.left + window.scrollX;
            if (left + popWidth > window.innerWidth + window.scrollX) {
                left = Math.max(8, window.innerWidth + window.scrollX - popWidth - 8);
            }
            pop.style.top = top + 'px';
            pop.style.left = left + 'px';
            pop.style.width = popWidth + 'px';
            pop.innerHTML =
                '<div style="font-size:11px;color:var(--muted);margin-bottom:4px;">每行一個連結(可貼上多個 URL)</div>' +
                '<textarea class="link-textarea" rows="6" placeholder="https://...&#10;https://...">' + escapeHtml(initial) + '</textarea>' +
                '<div class="filter-toolbar">' +
                    '<button type="button" class="ftb" data-act="clear">清空</button>' +
                    '<button type="button" class="ftb" data-act="cancel">取消</button>' +
                    '<button type="button" class="ftb primary" data-act="apply">套用</button>' +
                '</div>';
            document.body.appendChild(pop);
            linkEditorPop = pop;

            const ta = pop.querySelector('.link-textarea');
            ta.focus();
            // place cursor at end
            ta.setSelectionRange(ta.value.length, ta.value.length);

            pop.querySelector('[data-act="clear"]').addEventListener('click', () => { ta.value = ''; ta.focus(); });
            pop.querySelector('[data-act="cancel"]').addEventListener('click', closeLinkEditor);
            pop.querySelector('[data-act="apply"]').addEventListener('click', () => {
                const arr = parseLinks(ta.value);
                const newVal = arr.join('\n');
                if ((c[key] || '') !== newVal) {
                    c[key] = newVal;
                    markDirty(c.id);
                    const tr = anchor.closest('tr');
                    if (tr) {
                        const newTr = renderRow(c);
                        tr.replaceWith(newTr);
                    }
                }
                closeLinkEditor();
            });
            // Ctrl+Enter as a shortcut to apply
            ta.addEventListener('keydown', (e) => {
                if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
                    e.preventDefault();
                    pop.querySelector('[data-act="apply"]').click();
                }
            });
        }

        // click outside / ESC closes popover
        document.addEventListener('mousedown', (ev) => {
            if (activePopover) {
                if (!activePopover.contains(ev.target) &&
                    !(ev.target.closest && ev.target.closest('[data-act="filter"]'))) {
                    closeFilterPopover();
                }
            }
            if (linkEditorPop) {
                if (!linkEditorPop.contains(ev.target) &&
                    !(ev.target.closest && ev.target.closest('[data-act="edit-link"]'))) {
                    closeLinkEditor();
                }
            }
        }, true);

        // ---- Image upload (file -> base64), append model ----
        // Appends one or more data URLs to the target cell's image array.
        // After rebuild, the pending cell's td is refreshed so a subsequent
        // paste stays on the new DOM node.
        function appendImageDataUrls(dataUrls, opts) {
            opts = opts || {};
            const ctx = state.pendingImageCell;
            if (!ctx) return false;
            const c = state.cases.find(x => x.id === ctx.id);
            if (!c) return false;
            const arr = parseImages(c[ctx.key]);
            (Array.isArray(dataUrls) ? dataUrls : [dataUrls]).forEach(u => {
                if (u) arr.push(u);
            });
            c[ctx.key] = arr;
            const oldTr = ctx.td.closest('tr');
            if (oldTr) {
                const newTr = renderRow(c);
                oldTr.replaceWith(newTr);
                // Update td reference for continued paste mode
                const colIdx = COLUMNS.findIndex(co => co.key === ctx.key);
                if (colIdx >= 0 && newTr.children[colIdx]) {
                    ctx.td = newTr.children[colIdx];
                    if (opts.keepPasteMode) {
                        setPasteHighlight(ctx.td);
                    }
                }
            }
            markDirty(c.id);
            return true;
        }

        function setPasteHighlight(td) {
            clearPasteHighlight();
            td.classList.add('pasting');
        }
        function clearPasteHighlight() {
            document.querySelectorAll('td.img-cell.pasting').forEach(el => el.classList.remove('pasting'));
        }

        // ---- Clipboard paste (image only) ----
        // Stays in paste mode after a successful paste so the user can press
        // Ctrl+V repeatedly to append multiple images without re-clicking 貼上.
        document.addEventListener('paste', (ev) => {
            if (!state.pendingImageCell) return;
            const items = (ev.clipboardData && ev.clipboardData.items) || [];
            for (const it of items) {
                if (it.kind === 'file' && it.type && it.type.indexOf('image/') === 0) {
                    const blob = it.getAsFile();
                    if (!blob) continue;
                    ev.preventDefault();
                    const reader = new FileReader();
                    reader.onload = () => { appendImageDataUrls(reader.result, { keepPasteMode: true }); };
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
                closeFilterPopover();
                closeLinkEditor();
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

        // ---- Usage hint show/hide (remembered in localStorage) ----
        const usageHintEl = $('#usageHint');
        const usageHelpBtn = $('#btnHelp');
        function setUsageHintVisible(show) {
            if (show) {
                usageHintEl.classList.remove('collapsed');
                usageHelpBtn.style.display = 'none';
            } else {
                usageHintEl.classList.add('collapsed');
                usageHelpBtn.style.display = '';
            }
            try { localStorage.setItem('defect-lesson-hint', show ? '1' : '0'); } catch (e) {}
        }
        $('#usageClose').addEventListener('click', () => setUsageHintVisible(false));
        usageHelpBtn.addEventListener('click', () => setUsageHintVisible(true));
        try {
            if (localStorage.getItem('defect-lesson-hint') === '0') setUsageHintVisible(false);
        } catch (e) {}

        // ---- Search ----
        searchInput.addEventListener('input', renderAll);

        // ---- Add ----
        $('#btnAdd').addEventListener('click', () => {
            const c = { id: uid() };
            COLUMNS.forEach(col => { c[col.key] = ''; });
            state.cases.unshift(c);
            // clear filters so the new empty row is visible (otherwise looks like add did nothing)
            state.filters = {};
            document.querySelectorAll('#theadRow th[data-col].filtered').forEach(th => th.classList.remove('filtered'));
            renderAll();
            markDirty(c.id);
        });

        // ---- Clear all sort/filter ----
        $('#btnClearFilters').addEventListener('click', () => {
            state.sort = { key: null, dir: null };
            state.filters = {};
            document.querySelectorAll('#theadRow th[data-col]').forEach(th => {
                th.classList.remove('sort-asc', 'sort-desc', 'filtered');
                const sortEl = th.querySelector('.th-sort');
                if (sortEl) sortEl.textContent = '▲▼';
            });
            renderAll();
        });

        // ---- Save (per-case upsert + per-id delete) ----
        // Each modified/new case is sent individually so two users editing
        // different cases never overwrite each other's work.
        $('#btnSave').addEventListener('click', save);
        async function save() {
            const dirtyIds = [...state.dirtyIds];
            const deletedIds = [...state.deletedIds];
            const total = dirtyIds.length + deletedIds.length;
            if (total === 0) {
                setStatus('沒有變更');
                return;
            }
            let done = 0;
            try {
                // Upserts (modified / newly added cases)
                for (const id of dirtyIds) {
                    setStatus('儲存中 ' + (++done) + ' / ' + total + '...');
                    const c = state.cases.find(x => x.id === id);
                    if (!c) {
                        // Was added then deleted within the same session — nothing to send
                        state.dirtyIds.delete(id);
                        continue;
                    }
                    const res = await fetch('DefectLessonLearn.aspx?op=upsert', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json; charset=utf-8' },
                        body: JSON.stringify(c)
                    });
                    const data = await res.json();
                    if (!data || !data.ok) throw new Error('upsert ' + id + ': ' + (data && data.error || res.status));
                    state.dirtyIds.delete(id);
                }
                // Deletes
                for (const id of deletedIds) {
                    setStatus('儲存中 ' + (++done) + ' / ' + total + '...');
                    const res = await fetch('DefectLessonLearn.aspx?op=delete&id=' + encodeURIComponent(id), { method: 'POST' });
                    const data = await res.json();
                    if (!data || !data.ok) throw new Error('delete ' + id + ': ' + (data && data.error || res.status));
                    state.deletedIds.delete(id);
                }
                // Re-fetch so any changes made by OTHER users during our session are picked up
                await reloadFromServer({ silent: true });
                markSaved();
            } catch (e) {
                setStatus('儲存失敗: ' + e.message, 'error');
            }
        }

        async function reloadFromServer(opts) {
            opts = opts || {};
            const res = await fetch('DefectLessonLearn.aspx?op=list', { cache: 'no-store' });
            const data = await res.json();
            const fromServer = Array.isArray(data.cases) ? data.cases : [];
            fromServer.forEach(c => { if (!c.id) c.id = uid(); });
            // Preserve dirty / new local edits that haven't been saved yet
            const dirtyMap = new Map();
            state.cases.forEach(c => { if (state.dirtyIds.has(c.id)) dirtyMap.set(c.id, c); });
            // Build merged list: server cases first; locally-dirty rows override; locally-new rows appended
            const seen = new Set();
            const merged = fromServer.map(sc => {
                seen.add(sc.id);
                return dirtyMap.has(sc.id) ? dirtyMap.get(sc.id) : sc;
            });
            // Local-new rows (in dirtyIds but not on server) keep their place at the top
            const localNew = [];
            state.cases.forEach(c => {
                if (state.dirtyIds.has(c.id) && !seen.has(c.id)) localNew.push(c);
            });
            state.cases = [...localNew, ...merged];
            state.loadedIds = new Set(fromServer.map(c => c.id));
            renderAll();
        }

        window.addEventListener('beforeunload', (e) => {
            if (state.dirtyIds.size > 0 || state.deletedIds.size > 0) {
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
                // Remember which ids exist on disk — used by per-case save & delete logic
                state.loadedIds = new Set(state.cases.map(c => c.id));
                state.dirtyIds.clear();
                state.deletedIds.clear();
                decorateHeaders();
                renderAll();
            } catch (e) {
                setStatus('載入失敗: ' + e.message, 'error');
            }
        })();
    </script>
</body>
</html>
