<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LineYield.aspx.cs" Inherits="LineYield" ResponseEncoding="utf-8" %>

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
    <title>TF1/2 Line Yield System</title>
    <style>
        :root {
            color-scheme: dark;
            --bg: #0b1220;
            --bg-gradient: radial-gradient(1200px 600px at 20% 0%, #152a52 0%, #0b1220 60%);
            --panel: #0f1b33;
            --panel-elevated: #14233f;
            --text: #f3f7ff;
            --muted: #c6d0e6;
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
        html[data-theme="dark"] {
            color-scheme: dark;
            --bg: #0b1220;
            --bg-gradient: radial-gradient(1200px 600px at 20% 0%, #152a52 0%, #0b1220 60%);
            --panel: #0f1b33;
            --panel-elevated: #14233f;
            --text: #f3f7ff;
            --muted: #c6d0e6;
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
        html[data-theme="light"] {
            color-scheme: light;
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
        .last-edit {
            font-size: 11px;
            color: var(--muted);
            display: inline-flex;
            align-items: center;
            gap: 4px;
            flex-wrap: wrap;
        }
        .last-edit[hidden] { display: none; }
        .last-edit .who { color: var(--text); font-weight: 600; }
        .last-edit .when { color: var(--muted); }
        .last-edit .ref-chip {
            background: var(--chip);
            color: var(--text);
            padding: 1px 8px;
            border-radius: 999px;
            font-size: 11px;
            cursor: pointer;
            border: 1px solid transparent;
        }
        .last-edit .ref-chip:hover { background: var(--chip-active-bg); border-color: var(--chip-active-border); }

        /* ===== View tabs (Case Control Table / Trend Chart) ===== */
        .view-tabs {
            display: flex;
            gap: 6px;
            padding: 10px 0 4px;
            margin: 4px 0 14px;
            border-bottom: 1px solid var(--border);
        }
        .view-tabs button {
            padding: 8px 18px;
            background: transparent;
            border: 1px solid var(--border);
            border-bottom: none;
            border-radius: 10px 10px 0 0;
            color: var(--muted);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            position: relative;
            top: 1px;
        }
        .view-tabs button:hover { color: var(--text); background: var(--tint-med); }
        .view-tabs button.active {
            background: var(--panel);
            color: var(--text);
            border-color: var(--border);
            border-bottom: 1px solid var(--panel);
        }
        /* Dashboard hides the case table chrome. The case table is shown
           for either dataset view (light / bulk). */
        body.view-dashboard .case-only { display: none !important; }
        body.view-dashboard #viewCases     { display: none; }
        body.view-light     #viewDashboard,
        body.view-bulk      #viewDashboard { display: none; }
        .dashboard-wrap {
            border: 1px solid var(--border);
            border-radius: 12px;
            background: var(--panel);
            padding: 40px 28px;
            min-height: 360px;
        }
        .dashboard-wrap h2 { margin: 0 0 8px; font-size: 16px; }
        .dashboard-wrap .placeholder { color: var(--muted); line-height: 1.6; }

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
            /* Set color explicitly so cell text doesn't rely on inheritance
               from <body> — some Chromium versions don't recompute the
               inherited CSS var on a [data-theme] flip until next layout. */
            color: var(--text);
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
            /* Hide entirely until a column is actually sorted, then show
               a single arrow. Avoids the "header full of stacked arrows"
               clutter on every column. */
            display: none;
            font-size: 10px;
            line-height: 1;
        }
        table.cases thead th[data-col].sort-asc .th-sort,
        table.cases thead th[data-col].sort-desc .th-sort {
            display: inline;
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

        /* Cascading dropdown cells (現象1階 / ZE5.0 / ZE 1階 in 少片數) */
        td.cascade-cell select {
            width: 100%;
            min-width: 120px;
            padding: 4px 6px;
            background: var(--input-bg);
            color: var(--text);
            border: 1px solid var(--border);
            border-radius: 4px;
            font-family: inherit;
            font-size: 12px;
            outline: none;
            cursor: pointer;
        }
        td.cascade-cell select:focus { border-color: var(--accent); }
        td.cascade-cell select:disabled { color: var(--muted); cursor: not-allowed; opacity: 0.6; }
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
        /* Concrete width/height set by openOverlay() once the natural size
           is known so we can cap zoom at 2x while still respecting the
           viewport. */
        .img-overlay img { border-radius: 6px; }

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

        /* View / Edit mode toggle (same pill shape as theme toggle) */
        .mode-toggle {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 12px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: var(--chip);
            color: var(--text);
            font-size: 13px;
            cursor: pointer;
        }
        .mode-toggle:hover { background: var(--chip-active-bg); border-color: var(--chip-active-border); }
        body.view-mode .mode-toggle { background: var(--warn-bg); border-color: var(--warn-border); color: var(--warn); }
        .btn-logout {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 6px 12px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: var(--tint-med);
            color: var(--muted);
            font-size: 13px;
            cursor: pointer;
        }
        .btn-logout:hover { background: var(--warn-bg); color: var(--warn); border-color: var(--warn-border); }
        .btn-logout[hidden] { display: none; }
        /* Label text is set by JS (updateModeToggleLabel) so it can include
           the logged-in username dynamically. */
        /* ---- Login modal ---- */
        .login-overlay {
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.55);
            z-index: 10000;
            display: flex; align-items: center; justify-content: center;
        }
        .login-overlay[hidden] { display: none; }
        .login-card {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 22px 24px;
            min-width: 320px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
        }
        .login-card h3 { margin: 0 0 14px; color: var(--text); font-size: 16px; }
        .login-card label { display: block; font-size: 12px; color: var(--muted); margin: 8px 0 4px; }
        .login-card input[type="text"],
        .login-card input[type="password"] {
            width: 100%; box-sizing: border-box;
            background: var(--input-bg);
            border: 1px solid var(--border);
            color: var(--text);
            padding: 8px 10px;
            border-radius: 8px;
            font-size: 13px;
            outline: none;
        }
        .login-card input:focus { border-color: var(--accent); }
        .login-card .err {
            display: none;
            margin-top: 10px;
            padding: 6px 10px;
            font-size: 12px;
            color: var(--warn);
            background: var(--warn-bg);
            border: 1px solid var(--warn-border);
            border-radius: 6px;
        }
        .login-card .err.show { display: block; }
        .login-card .actions {
            margin-top: 16px;
            display: flex; gap: 8px; justify-content: flex-end;
        }
        /* View-mode hides every UI that can mutate data */
        body.view-mode #btnAdd,
        body.view-mode #btnSave,
        body.view-mode table.cases td.actions,
        body.view-mode table.cases thead th:last-child,
        body.view-mode td.img-cell .thumb-x,
        body.view-mode td.img-cell .img-empty,
        body.view-mode [data-act="edit-link"] { display: none !important; }
        /* In view mode, non-editable cells stop showing the text caret */
        body.view-mode .cell-text { cursor: default; }
        body.view-mode .cell-text:focus { outline: none; box-shadow: none; }

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

        /* ===== AI assistant floating bubble + panel ===== */
        #aiBubble {
            position: fixed;
            right: 22px;
            bottom: 22px;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            border: none;
            cursor: pointer;
            background: linear-gradient(135deg, var(--accent) 0%, var(--accent-strong) 100%);
            color: #fff;
            font-weight: 700;
            font-size: 16px;
            letter-spacing: 0.5px;
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.45), 0 2px 6px rgba(0,0,0,0.25);
            z-index: 9999;
            transition: transform .15s ease, box-shadow .15s ease;
        }
        #aiBubble:hover { transform: translateY(-2px); box-shadow: 0 12px 28px rgba(37, 99, 235, 0.55), 0 3px 8px rgba(0,0,0,0.3); }
        #aiBubble.open { transform: scale(0.9); }
        #aiPanel {
            position: fixed;
            right: 22px;
            bottom: 90px;
            width: 800px;
            height: 760px;
            max-width: calc(100vw - 44px);
            max-height: calc(100vh - 120px);
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 14px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.45), 0 4px 12px rgba(0,0,0,0.2);
            display: flex;
            flex-direction: row;
            overflow: hidden;
            z-index: 9999;
        }
        #aiPanel[hidden] { display: none; }
        .ai-sidebar {
            width: 160px;
            flex: none;
            display: flex;
            flex-direction: column;
            background: var(--panel-elevated);
            border-right: 1px solid var(--border);
        }
        .ai-new-btn {
            margin: 8px;
            padding: 6px 10px;
            border-radius: 8px;
            background: var(--accent);
            color: #fff;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
        }
        .ai-new-btn:hover { background: var(--accent-strong); }
        .ai-sess-list {
            flex: 1;
            overflow-y: auto;
            padding: 0 6px 6px;
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .ai-sess {
            position: relative;
            padding: 6px 8px;
            border-radius: 8px;
            cursor: pointer;
            border: 1px solid transparent;
        }
        .ai-sess:hover { background: var(--row-hover); }
        .ai-sess.active { background: var(--tint-high); border-color: var(--chip-active-border); }
        .ai-sess-title {
            font-size: 12px;
            color: var(--text);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding-right: 16px;
        }
        .ai-sess-meta { font-size: 10px; color: var(--muted); margin-top: 2px; }
        .ai-sess-tags { display: flex; flex-wrap: wrap; gap: 3px; margin-top: 4px; }
        .ai-sess-tags .tag {
            font-size: 10px;
            padding: 1px 6px;
            border-radius: 999px;
            background: var(--chip);
            color: var(--muted);
        }
        .ai-sess-del {
            position: absolute;
            top: 4px; right: 4px;
            background: transparent;
            border: none;
            color: var(--muted);
            cursor: pointer;
            font-size: 14px;
            line-height: 1;
            padding: 0 4px;
            border-radius: 4px;
            opacity: 0;
            transition: opacity .12s;
        }
        .ai-sess:hover .ai-sess-del,
        .ai-sess.active .ai-sess-del { opacity: 1; }
        .ai-sess-del:hover { background: var(--warn-bg); color: var(--danger); }
        .ai-sess-footer {
            padding: 6px 10px;
            border-top: 1px solid var(--border);
            color: var(--muted);
            font-size: 11px;
        }
        .ai-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            min-width: 0;
        }
        .ai-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            background: linear-gradient(135deg, rgba(99,179,237,0.15), rgba(37,99,235,0.10));
            border-bottom: 1px solid var(--border);
        }
        .ai-title { font-weight: 600; color: var(--text); font-size: 14px; }
        .ai-title small { color: var(--muted); font-weight: 400; margin-left: 6px; }
        .ai-title-input {
            flex: 1;
            min-width: 0;
            background: transparent;
            border: 1px solid transparent;
            color: var(--text);
            font-weight: 600;
            font-size: 14px;
            outline: none;
            padding: 4px 8px;
            border-radius: 6px;
        }
        .ai-title-input:hover { background: var(--tint-med); }
        .ai-title-input:focus { background: var(--tint-med); border-color: var(--accent); }
        .ai-tags-row {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 4px;
            padding: 6px 12px;
            border-bottom: 1px solid var(--border);
            background: var(--panel-elevated);
            min-height: 30px;
        }
        .ai-tag-chip {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            background: var(--chip);
            color: var(--text);
            border: 1px solid var(--chip-active-border);
            border-radius: 999px;
            padding: 2px 4px 2px 8px;
            font-size: 11px;
        }
        .ai-tag-chip .x {
            background: transparent;
            border: none;
            color: var(--muted);
            cursor: pointer;
            padding: 0 4px;
            line-height: 1;
            border-radius: 4px;
        }
        .ai-tag-chip .x:hover { background: var(--warn-bg); color: var(--danger); }
        .ai-tag-add {
            background: transparent;
            border: 1px dashed var(--border);
            color: var(--muted);
            border-radius: 999px;
            padding: 2px 10px;
            font-size: 11px;
            cursor: pointer;
        }
        .ai-tag-add:hover { color: var(--text); border-color: var(--accent); }
        #aiClose {
            background: transparent; border: none; color: var(--muted);
            font-size: 22px; line-height: 1; cursor: pointer; padding: 2px 6px;
            border-radius: 6px;
        }
        #aiClose:hover { background: var(--tint-med); color: var(--text); }
        .ai-msgs {
            flex: 1;
            overflow-y: auto;
            padding: 14px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .ai-msg { max-width: 86%; padding: 8px 12px; border-radius: 12px; font-size: 13px; line-height: 1.5; white-space: pre-wrap; word-wrap: break-word; }
        .ai-msg.user { align-self: flex-end; background: var(--accent-strong); color: #fff; border-bottom-right-radius: 4px; }
        .ai-msg.assistant { align-self: flex-start; background: var(--tint-med); color: var(--text); border-bottom-left-radius: 4px; }
        .ai-msg.error { align-self: stretch; background: var(--warn-bg); border: 1px solid var(--warn-border); color: var(--warn); font-size: 12px; }
        .ai-msg.typing { align-self: flex-start; background: var(--tint-med); color: var(--muted); }
        .ai-msg.typing .dot { display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: var(--muted); margin: 0 2px; animation: ai-blink 1.2s infinite; }
        .ai-msg.typing .dot:nth-child(2) { animation-delay: .2s; }
        .ai-msg.typing .dot:nth-child(3) { animation-delay: .4s; }
        @keyframes ai-blink { 0%, 80%, 100% { opacity: 0.25; } 40% { opacity: 1; } }
        .ai-input-wrap {
            border-top: 1px solid var(--border);
            padding: 10px;
            display: flex;
            gap: 8px;
            background: var(--panel-elevated);
        }
        #aiInput {
            flex: 1;
            min-height: 38px;
            max-height: 120px;
            resize: none;
            padding: 8px 10px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: var(--input-bg);
            color: var(--text);
            font-family: inherit;
            font-size: 13px;
            outline: none;
        }
        #aiInput:focus { border-color: var(--accent); }
        #aiSend { white-space: nowrap; }
        #aiSend:disabled { opacity: 0.5; cursor: not-allowed; }
        .ai-icon-btn {
            background: var(--tint-med);
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: 8px;
            width: 38px;
            height: 38px;
            display: inline-flex; align-items: center; justify-content: center;
            cursor: pointer; flex: none;
        }
        .ai-icon-btn:hover { background: var(--tint-high); border-color: var(--accent); }
        .ai-preview {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 10px;
            background: var(--panel-elevated);
            border-top: 1px solid var(--border);
        }
        .ai-preview[hidden] { display: none; }
        .ai-preview img {
            max-height: 56px;
            max-width: 90px;
            border-radius: 6px;
            border: 1px solid var(--border);
            object-fit: contain;
            background: #000;
        }
        .ai-preview .ai-prev-meta { color: var(--muted); font-size: 12px; flex: 1; }
        .ai-preview .ai-prev-remove {
            background: var(--tint-med);
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: 6px;
            padding: 4px 10px;
            cursor: pointer;
            font-size: 12px;
        }
        .ai-preview .ai-prev-remove:hover { background: var(--warn-bg); color: var(--warn); border-color: var(--warn-border); }
        .ai-msg-img {
            margin-top: 6px;
            max-width: 220px;
            max-height: 160px;
            border-radius: 8px;
            display: block;
            border: 1px solid rgba(255,255,255,0.15);
        }
        .ai-refs {
            align-self: flex-start;
            margin-top: -2px;
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            align-items: center;
            font-size: 12px;
            color: var(--muted);
            max-width: 90%;
        }
        .ai-ref-label { margin-right: 2px; }
        .ai-ref-chip {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 999px;
            background: var(--chip);
            border: 1px solid var(--chip-active-border);
            color: var(--text);
            cursor: pointer;
            font-size: 12px;
            transition: background .15s;
        }
        .ai-ref-chip:hover { background: var(--chip-active-bg); }
        .ai-refs-apply {
            margin-left: 4px;
            padding: 3px 10px;
            border-radius: 999px;
            border: 1px solid var(--accent);
            background: var(--accent);
            color: #fff;
            font-size: 12px;
            cursor: pointer;
        }
        .ai-refs-apply:hover { background: var(--accent-strong); border-color: var(--accent-strong); }
        /* Row flash when a [#N] chip jumps to a case */
        @keyframes ai-row-flash {
            0%   { background: rgba(99,179,237,0.40); }
            100% { background: transparent; }
        }
        tr.ai-flash > td { animation: ai-row-flash 1.6s ease-out; }
        /* Auto-detected near-duplicate notice under a user image upload */
        .ai-hash-hint {
            align-self: center;
            font-size: 11px;
            color: var(--accent);
            background: rgba(99,179,237,0.10);
            border: 1px dashed var(--chip-active-border);
            border-radius: 8px;
            padding: 4px 10px;
            max-width: 90%;
            text-align: center;
        }
        /* AI-suggested new-case preview card */
        .ai-newcase-card {
            align-self: stretch;
            background: var(--panel-elevated);
            border: 1px solid var(--accent);
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 12px;
            color: var(--text);
        }
        .ai-newcase-title {
            font-weight: 600;
            color: var(--accent);
            margin-bottom: 6px;
            font-size: 12px;
        }
        .ai-newcase-fields {
            display: flex;
            flex-direction: column;
            gap: 3px;
            margin-bottom: 10px;
            max-height: 240px;
            overflow-y: auto;
            background: var(--input-bg);
            border-radius: 6px;
            padding: 6px 8px;
        }
        .ai-newcase-fields > div { line-height: 1.45; word-break: break-word; }
        .ai-newcase-key {
            color: var(--muted);
            font-weight: 500;
            margin-right: 6px;
            display: inline-block;
            min-width: 90px;
        }
        .ai-newcase-actions { display: flex; gap: 6px; }
        .ai-newcase-add, .ai-newcase-dismiss {
            flex: 1;
            padding: 6px 10px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 12px;
            border: 1px solid var(--border);
            font-weight: 500;
        }
        .ai-newcase-add { background: var(--accent); color: #fff; border-color: var(--accent); }
        .ai-newcase-add:hover { background: var(--accent-strong); border-color: var(--accent-strong); }
        .ai-newcase-add:disabled { background: var(--tint-med); color: var(--muted); cursor: default; border-color: var(--border); }
        .ai-newcase-dismiss { background: transparent; color: var(--muted); }
        .ai-newcase-dismiss:hover { color: var(--text); background: var(--tint-med); }
    </style>
</head>
<body>
    <!-- Login modal shown when entering edit mode without a session. -->
    <div id="loginOverlay" class="login-overlay" hidden>
        <div class="login-card">
            <h3>進入編輯模式</h3>
            <form id="loginForm">
                <label>使用者</label>
                <input type="text" id="loginUser" autocomplete="username" required />
                <label>密碼</label>
                <input type="password" id="loginPwd" autocomplete="current-password" required />
                <div class="err" id="loginErr"></div>
                <div class="actions">
                    <button type="button" id="loginCancel" class="btn">取消</button>
                    <button type="submit" id="loginSubmit" class="btn btn-primary">登入</button>
                </div>
            </form>
        </div>
    </div>
    <div class="container">
        <div class="header">
            <h1>TF1/2 Line Yield System</h1>
            <span class="subtitle">內嵌 base64 圖片 + 可編輯/搜尋 / 自動寫回 JSON</span>
            <div class="view-tabs">
                <button type="button" data-view="dashboard" class="active">Dashboard</button>
                <button type="button" data-view="light">少片數報廢</button>
                <button type="button" data-view="bulk">大宗報廢</button>
            </div>
            <div class="toolbar">
                <input type="search" id="searchInput" class="search case-only" placeholder="搜尋任一欄位文字..." />
                <button type="button" id="btnAdd" class="btn btn-primary case-only">+ 新增 Case</button>
                <button type="button" id="btnClearFilters" class="btn case-only" title="清除所有排序與篩選">↻ 清除篩選</button>
                <button type="button" id="btnSave" class="btn case-only">儲存</button>
                <button type="button" id="btnHelp" class="btn-help case-only" title="顯示操作提示" style="display:none;">?</button>
                <button type="button" id="modeToggle" class="mode-toggle case-only" title="切換唯讀 / 編輯模式">
                    <span class="mode-toggle-label"></span>
                </button>
                <button type="button" id="btnLogout" class="btn-logout" title="登出" hidden>登出</button>
                <button type="button" id="themeToggle" class="theme-toggle" title="切換深色 / 淺色">
                    <span class="theme-toggle-icon"></span>
                    <span class="theme-toggle-label"></span>
                </button>
                <span id="statusPill" class="status-pill">載入中...</span>
                <span id="lastEdit" class="last-edit case-only" hidden></span>
            </div>
        </div>

        <div id="viewDashboard" class="dashboard-wrap">
            <h2>Dashboard</h2>
            <div class="placeholder">圖表內容待加入。</div>
        </div>

        <div id="viewCases">
        <div class="usage-hint case-only" id="usageHint">
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
                    <!-- Header cells are rendered by applyColumnSchema() so the
                         layout follows whichever dataset (light / bulk) is
                         currently active. -->
                    <tr id="theadRow"></tr>
                </thead>
                <tbody id="tbody"></tbody>
            </table>
        </div>
        </div><!-- /#viewCases -->
    </div>

    <!-- AI assistant floating bubble + chat panel -->
    <button id="aiBubble" type="button" title="AI 助理">AI</button>
    <div id="aiPanel" hidden>
        <div class="ai-sidebar">
            <button type="button" id="aiNewChat" class="ai-new-btn">+ 新聊天</button>
            <div id="aiSessionList" class="ai-sess-list"></div>
            <div class="ai-sess-footer" id="aiCaseCount">已載入 0 筆 case</div>
        </div>
        <div class="ai-main">
            <div class="ai-head">
                <input type="text" id="aiTitle" class="ai-title-input" placeholder="對話標題" />
                <button type="button" id="aiClose" title="關閉">×</button>
            </div>
            <div class="ai-tags-row" id="aiTagsRow"></div>
            <div id="aiMessages" class="ai-msgs"></div>
            <div id="aiPreview" class="ai-preview" hidden>
                <img id="aiPreviewImg" alt="附加圖片" />
                <span class="ai-prev-meta" id="aiPreviewMeta"></span>
                <button type="button" class="ai-prev-remove" id="aiPreviewRemove" title="移除附圖">移除</button>
            </div>
            <div class="ai-input-wrap">
                <button type="button" id="aiAttach" class="ai-icon-btn" title="附加圖片(可貼上)">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/>
                    </svg>
                </button>
                <input type="file" id="aiFile" accept="image/*" hidden />
                <textarea id="aiInput" placeholder="輸入問題,可附圖搜尋相關 case。Enter 送出,Shift+Enter 換行" rows="2"></textarea>
                <button type="button" id="aiSend" class="btn btn-primary">送出</button>
            </div>
        </div>
    </div>

    <script>
        // ---- Column schemas per dataset ----
        // Each schema is the source of truth for both the THEAD layout and
        // the per-row cell rendering.  COLUMNS is a mutable reference that
        // points at whichever schema the active dataset uses.
        //   - kind 'img'  : image upload + thumbnail grid
        //   - kind 'link' : multi-URL editor (one link per line)
        //   - default     : plain editable text
        const COLUMNS_BULK = [
            { key: 'waferMap',     label: 'Wafer map',           kind: 'img' },
            { key: 'image',        label: 'Image',               kind: 'img' },
            { key: 'date',         label: '時間' },
            { key: 'category',     label: '異常類別' },
            { key: 'link',         label: 'Link',                kind: 'link' },
            { key: 'parts',        label: '異常 parts' },
            { key: 'rootCause',    label: 'Root cause & Action' },
            { key: 'entityRecipe', label: 'Entity / Recipe' },
            { key: 'equipment',    label: '異常機台' },
            { key: 'impact',       label: 'Impact / 報廢' },
            { key: 'generation',   label: 'Generation' },
            { key: 'productModel', label: '產品型號' },
            { key: 'defectType',   label: 'Defect type' },
            { key: 'map',          label: 'Map' },
            { key: 'edx',          label: 'EDX' },
            { key: 'waferTrend',   label: 'Wafer Trend' },
            { key: 'position',     label: '對應位置' },
            { key: 'other',        label: '其他特徵' }
        ];

        // 少片數報廢:no image columns, Link is the multi-URL editor,
        // every other column is plain text input.
        const COLUMNS_LIGHT = [
            { key: 'link',          label: 'Link',                  kind: 'link' },
            { key: 'reviewAR',      label: '已review AR' },
            { key: 'generation',    label: 'Generation' },
            { key: 'owner',         label: 'owner' },
            { key: 'category',      label: '分類填寫' },
            { key: 'createDate',    label: 'Create_date' },
            { key: 'lotId',         label: 'LotID' },
            { key: 'qty',           label: 'Qty' },
            { key: 'eqpId',         label: 'EqpID' },
            { key: 'reason',        label: '原因' },
            { key: 'rootCause',     label: 'Root cause' },
            { key: 'parts',         label: 'Parts' },
            { key: 'finalAction',   label: 'Final_Action' },
            { key: 'phenomenon1',   label: '現象1階',              kind: 'cascade' },
            { key: 'ze50',          label: 'ZE5.0',                kind: 'cascade' },
            { key: 'ze1',           label: 'ZE 1階',               kind: 'cascade' },
            { key: 'meetingUpdate', label: 'meeting update' },
            { key: 'productType',   label: 'auto or normal 產品' }
        ];

        let COLUMNS = COLUMNS_LIGHT;

        // Cascading dropdown options for the 少片數 schema.
        //   Level 1: phenomenon1  (現象1階)
        //   Level 2: ze50         (ZE5.0) depends on phenomenon1
        //   Level 3: ze1          (ZE 1階) depends on phenomenon1 + ze50
        // Categories 0-2 (天災 / BKM Change / Eng.Request) have no sub-options
        // so their dependent cells stay disabled.
        const CASCADE_DATA = {
            phenomenon1: [
                '0.天災',
                '1.BKM Change',
                '2.Eng.Request',
                '3.MO',
                '4.Tool Down',
                '5.Wafer Broken',
                '6.Scratch OOS',
                '7.Defect OOS',
                '8.WAT/In-line OOS'
            ],
            ze50: {
                '0.天災':            [],
                '1.BKM Change':      [],
                '2.Eng.Request':     [],
                '3.MO':              ['2.不製造'],
                '4.Tool Down':       ['1.不接受', '2.不製造', '3.不流出'],
                '5.Wafer Broken':    ['1.不接受', '2.不製造', '3.不流出'],
                '6.Scratch OOS':     ['1.不接受', '2.不製造', '3.不流出'],
                '7.Defect OOS':      ['1.不接受', '2.不製造', '3.不流出'],
                '8.WAT/In-line OOS': ['1.不接受', '2.不製造', '3.不流出']
            },
            ze1: {
                '3.MO|2.不製造': ['3.1.Mindset & Training'],

                '4.Tool Down|1.不接受': [
                    '4.1.Incoming Material/ Incoming Parts Management',
                    '4.2.Process Robustness',
                    '4.3.Change Management'
                ],
                '4.Tool Down|2.不製造': [
                    '4.4.PM Management',
                    '4.5.設備失效 (EQ malfunction)',
                    '4.6.Mindset & Training'
                ],
                '4.Tool Down|3.不流出': [
                    '4.7.Tool matching',
                    '4.8.Unknown'
                ],

                '5.Wafer Broken|1.不接受': [
                    '5.1.Incoming Material/ Incoming Parts Management',
                    '5.2.Process Robustness',
                    '5.3.Change Management'
                ],
                '5.Wafer Broken|2.不製造': [
                    '5.4.PM Management',
                    '5.5.設備失效 (EQ malfunction)',
                    '5.6.Mindset & Training'
                ],
                '5.Wafer Broken|3.不流出': [
                    '5.7.Tool matching',
                    '5.8.Unknown'
                ],

                '6.Scratch OOS|1.不接受': [
                    '6.1.Incoming Material/ Incoming Parts Management',
                    '6.2.Process Robustness',
                    '6.3.Change Management'
                ],
                '6.Scratch OOS|2.不製造': [
                    '6.4.PM Management',
                    '6.5.設備失效 (EQ malfunction)',
                    '6.6.Mindset & Training'
                ],
                '6.Scratch OOS|3.不流出': [
                    '6.7.Unknown'
                ],

                '7.Defect OOS|1.不接受': [
                    '7.1.Incoming Material/ Incoming Parts Management',
                    '7.2.Process Robustness',
                    '7.3.Change Management'
                ],
                '7.Defect OOS|2.不製造': [
                    '7.4.PM Management',
                    '7.5.設備失效 (EQ malfunction)',
                    '7.6.Tool matching'
                ],
                '7.Defect OOS|3.不流出': [
                    '7.7.Unknown'
                ],

                '8.WAT/In-line OOS|1.不接受': [
                    '8.1.Incoming Material/ Incoming Parts Management',
                    '8.2.Process Robustness',
                    '8.3.Change Management'
                ],
                '8.WAT/In-line OOS|2.不製造': [
                    '8.4.PM Management',
                    '8.5.設備失效 (EQ malfunction)',
                    '8.6.Tool matching'
                ],
                '8.WAT/In-line OOS|3.不流出': [
                    '8.7.Unknown'
                ]
            }
        };

        function cascadeOptionsFor(key, c) {
            if (key === 'phenomenon1') return CASCADE_DATA.phenomenon1.slice();
            if (key === 'ze50') {
                const p = c.phenomenon1 || '';
                return (CASCADE_DATA.ze50[p] || []).slice();
            }
            if (key === 'ze1') {
                const p1 = c.phenomenon1 || '';
                const p2 = c.ze50 || '';
                return (CASCADE_DATA.ze1[p1 + '|' + p2] || []).slice();
            }
            return [];
        }

        function applyColumnSchema(datasetName) {
            COLUMNS = datasetName === 'bulk' ? COLUMNS_BULK : COLUMNS_LIGHT;
            const theadRow = document.getElementById('theadRow');
            if (!theadRow) return;
            const cells = COLUMNS.map(col => {
                if (col.kind === 'img') {
                    return '<th class="col-img">' + escapeHtml(col.label) + '</th>';
                }
                return '<th data-col="' + col.key + '">' + escapeHtml(col.label) + '</th>';
            });
            // Trailing empty header for the per-row delete-action cell.
            cells.push('<th></th>');
            theadRow.innerHTML = cells.join('');
            decorateHeaders();
        }

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
            loadedIds: new Set(),
            // Set by the AI panel via applyAiFilter(); null = no AI filter.
            aiFilterIds: null,
            // Which dataset the table is currently bound to.  Driven by the
            // view tabs; "light" = 少片數報廢, "bulk" = 大宗報廢.
            currentDataset: 'light',
            // View-only mode: cells become non-editable and all mutation UI
            // (+ 新增 / 儲存 / 刪除 / image upload / link edit) is hidden.
            // Defaults to TRUE so first-time visitors can't accidentally edit
            // while browsing; persisted in localStorage so daily editors only
            // need to toggle once.
            // Edit mode also requires a fresh-tab login. So a tab that was last
            // saved in edit mode but no longer has a login session starts in
            // view mode and the user has to log in again.
            viewMode: (localStorage.getItem('defectLL.viewMode') !== '0') || !sessionStorage.getItem('defectLL.authUser')
        };
        // Apply the initial body class before the first render so cells get
        // contenteditable set correctly the first time.
        if (state.viewMode) document.body.classList.add('view-mode');

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
                        // View mode: still allow zooming on a thumbnail image,
                        // but no remove / clear / paste-mode activation.
                        if (state.viewMode) {
                            if (ev.target.tagName === 'IMG') openOverlay(ev.target.src);
                            return;
                        }
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
                        if (state.viewMode) return;
                        ev.preventDefault();
                        td.classList.add('drop-target');
                    });
                    td.addEventListener('dragleave', () => {
                        td.classList.remove('drop-target');
                    });
                    td.addEventListener('drop', (ev) => {
                        if (state.viewMode) return;
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
                        if (state.viewMode) return;
                        openLinkEditor(c, col.key, td);
                    });
                } else if (col.kind === 'cascade') {
                    // 3-level cascading dropdown (現象1階 -> ZE5.0 -> ZE 1階).
                    // In view-only mode just print the value as text.
                    td.className = 'editable cascade-cell';
                    const v = c[col.key] || '';
                    if (state.viewMode) {
                        td.innerHTML = '<div class="cell-text">' + escapeHtml(v) + '</div>';
                    } else {
                        const opts = cascadeOptionsFor(col.key, c);
                        const select = document.createElement('select');
                        select.setAttribute('data-key', col.key);
                        const blank = document.createElement('option');
                        blank.value = '';
                        blank.textContent = opts.length === 0 ? '(無選項)' : '(請選擇)';
                        select.appendChild(blank);
                        opts.forEach(opt => {
                            const o = document.createElement('option');
                            o.value = opt;
                            o.textContent = opt;
                            if (opt === v) o.selected = true;
                            select.appendChild(o);
                        });
                        if (opts.length === 0) select.disabled = true;
                        // Edge case: the saved value isn't in the current option
                        // set (e.g. parent column changed externally). Show it
                        // so the user can see it but mark it as "(舊值)".
                        if (v && opts.indexOf(v) < 0) {
                            const stale = document.createElement('option');
                            stale.value = v;
                            stale.textContent = v + '  (舊值)';
                            stale.selected = true;
                            select.appendChild(stale);
                        }
                        select.addEventListener('change', () => {
                            c[col.key] = select.value;
                            // Changing a parent must clear its descendants so a
                            // stale combo (e.g. ze1 from previous phenomenon1)
                            // doesn't survive.
                            if (col.key === 'phenomenon1') { c.ze50 = ''; c.ze1 = ''; }
                            else if (col.key === 'ze50')   { c.ze1 = ''; }
                            markDirty(c.id);
                            // Re-render the row so the dependent dropdowns pick
                            // up their new option lists.
                            const newTr = renderRow(c);
                            tr.replaceWith(newTr);
                        });
                        td.innerHTML = '';
                        td.appendChild(select);
                    }
                } else {
                    td.className = 'editable';
                    const v = c[col.key] || '';
                    const editable = state.viewMode ? 'false' : 'true';
                    td.innerHTML = '<div class="cell-text" contenteditable="' + editable + '" data-key="' + col.key + '">' + escapeHtml(v) + '</div>';
                }

                // Only wire edit handlers when the cell is actually editable —
                // otherwise paste/blur listeners run unnecessarily in view mode.
                if (!state.viewMode && td.querySelector('.cell-text[contenteditable="true"]')) {
                    wireEditable(td.querySelector('.cell-text[contenteditable="true"]'), c);
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
            // AI-driven filter (set by clicking "在表格只顯示這些" in a chat reply)
            if (state.aiFilterIds && state.aiFilterIds.size > 0) {
                rows = rows.filter(c => state.aiFilterIds.has(c.id));
            }
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
            if (state.aiFilterIds && state.aiFilterIds.size > 0) {
                // Hint that the count is constrained by an AI filter, with a quick clear.
                statusPill.className = 'status-pill dirty';
                statusPill.innerHTML = 'AI 篩選中: ' + shown + ' 筆 ' +
                    '<a href="#" id="aiFilterClearLink" style="margin-left:6px;text-decoration:underline;">清除</a>';
                const link = document.getElementById('aiFilterClearLink');
                if (link) link.addEventListener('click', (e) => { e.preventDefault(); clearAiFilter(); });
                return;
            }
            if (shown === total) {
                setStatus('共 ' + total + ' 筆');
            } else {
                setStatus('顯示 ' + shown + ' / ' + total + ' 筆', 'dirty');
            }
        }

        // ---- AI-driven filter (applied from chat panel) ----
        function applyAiFilter(caseNumbers) {
            const ids = new Set();
            caseNumbers.forEach(n => {
                const c = state.cases[n - 1];
                if (c) ids.add(c.id);
            });
            if (ids.size === 0) return;
            state.aiFilterIds = ids;
            renderAll();
            // Scroll the first matched row into view for immediate feedback.
            const firstId = ids.values().next().value;
            const firstTr = document.querySelector('tr[data-id="' + firstId + '"]');
            if (firstTr) firstTr.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        function clearAiFilter() {
            state.aiFilterIds = null;
            renderAll();
        }
        function scrollToCaseByNumber(n) {
            const c = state.cases[n - 1];
            if (!c) return;
            // If current visibility hides this row, drop the AI filter so it can show.
            // (Regular per-column filters / search are left alone — user can clear themselves.)
            if (state.aiFilterIds && !state.aiFilterIds.has(c.id)) {
                state.aiFilterIds.add(c.id);
                renderAll();
            }
            const tr = document.querySelector('tr[data-id="' + c.id + '"]');
            if (!tr) return;
            tr.scrollIntoView({ behavior: 'smooth', block: 'center' });
            tr.classList.add('ai-flash');
            setTimeout(() => tr.classList.remove('ai-flash'), 1600);
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
                // Skip if already decorated. decorateHeaders() is called on
                // every loadData(), and dataset-switching re-runs loadData,
                // which would otherwise re-read th.textContent (now including
                // the previous run's chevron) and stack a new "▾" on top each
                // time -- producing "時間 ▾ ▾ ▾ ..." in the header.
                if (th.querySelector('.th-inner')) return;
                const key = th.getAttribute('data-col');
                const label = th.textContent.trim();
                th.innerHTML =
                    '<div class="th-inner">' +
                        '<span class="th-label">' + escapeHtml(label) + '</span>' +
                        '<span class="th-sort"></span>' +
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
                if (sortEl) sortEl.textContent = '';
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
            if (state.viewMode) return;
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
            // Cap zoom at 2x native size, but also fit inside 95% of the
            // viewport. The smaller of those two limits wins, preserving
            // aspect ratio so the image is never stretched.
            const sizeIt = () => {
                const nw = img.naturalWidth, nh = img.naturalHeight;
                if (!nw || !nh) return;
                const ZOOM = 2;
                const scale = Math.min(
                    ZOOM,
                    (window.innerWidth  * 0.95) / nw,
                    (window.innerHeight * 0.95) / nh
                );
                img.style.width  = (nw * scale) + 'px';
                img.style.height = (nh * scale) + 'px';
            };
            img.onload = sizeIt;
            img.src = src;
            if (img.complete) sizeIt(); // cached images may not fire onload
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

        // ---- Local-style auth (no token, server only validates on login) ----
        function getAuthUser() {
            try { return sessionStorage.getItem('defectLL.authUser') || ''; } catch (e) { return ''; }
        }
        function getAuthToken() {
            try { return sessionStorage.getItem('defectLL.authToken') || ''; } catch (e) { return ''; }
        }
        function getAuthRole() {
            try { return sessionStorage.getItem('defectLL.authRole') || 'editor'; } catch (e) { return 'editor'; }
        }
        function isViewer() { return getAuthRole() !== 'editor'; }
        function setAuthUser(name, token, role) {
            try {
                sessionStorage.setItem('defectLL.authUser', name);
                if (token) sessionStorage.setItem('defectLL.authToken', token);
                sessionStorage.setItem('defectLL.authRole', role || 'editor');
            } catch (e) {}
            updateModeToggleLabel();
            applyRoleVisibility();
            resetIdleTimer();
        }
        // Viewers must never see the edit toggle, can never leave view-mode,
        // and the body keeps the view-mode class so all mutation UI stays
        // hidden. Called whenever auth changes.
        function applyRoleVisibility() {
            const viewer = isViewer() && !!getAuthUser();
            const toggle = document.getElementById('modeToggle');
            if (toggle) toggle.style.display = viewer ? 'none' : '';
            if (viewer) {
                state.viewMode = true;
                document.body.classList.add('view-mode');
            }
        }
        // Wraps fetch: auto-attaches X-Auth-Token, and on any
        //   { ok: false, error: "needLogin" }
        // body (sent by RequireAuth on the server when the token is missing,
        // expired or unknown) immediately tears the session down and pops
        // the login modal.
        async function authFetch(url, opts) {
            opts = opts || {};
            const headers = Object.assign({}, opts.headers || {});
            const tok = getAuthToken();
            if (tok) headers['X-Auth-Token'] = tok;
            const res = await fetch(url, Object.assign({}, opts, { headers: headers }));
            try {
                const peek = await res.clone().json();
                if (peek && peek.ok === false && peek.error === 'needLogin') {
                    performLogout('登入逾期,請重新登入', { preserveData: true });
                }
            } catch (e) { /* not JSON; ignore */ }
            return res;
        }
        function updateModeToggleLabel() {
            const el = document.querySelector('#modeToggle .mode-toggle-label');
            if (!el) return;
            const u = getAuthUser();
            if (state.viewMode) {
                el.textContent = u ? ('唯讀中 — ' + u + ' (點此編輯)') : '唯讀中 (點此編輯)';
            } else {
                el.textContent = u ? ('編輯中: ' + u + ' (點此鎖定)') : '編輯中 (點此鎖定)';
            }
            // Logout button is visible only while a user is logged in.
            const lo = document.getElementById('btnLogout');
            if (lo) lo.hidden = !u;
        }

        // ---- Logout (manual button + 5-min idle auto) ----
        // performLogout(reason, opts)
        //   opts.preserveData = true  -> involuntary logout (token expired
        //                                mid-action). Keep state.cases /
        //                                dirtyIds / deletedIds so the user
        //                                does NOT lose unsaved edits. After
        //                                the re-login modal closes we run
        //                                reloadFromServer which merges the
        //                                preserved dirty rows with the fresh
        //                                server data.
        //   opts.preserveData = false (default) -> manual logout. Wipe state
        //                                so a closed session can't be peeked
        //                                via dev tools.
        function performLogout(reason, opts) {
            opts = opts || {};
            const preserve = !!opts.preserveData;
            try {
                sessionStorage.removeItem('defectLL.authUser');
                sessionStorage.removeItem('defectLL.authToken');
                sessionStorage.removeItem('defectLL.authRole');
            } catch (e) {}
            // Force back into view mode and drop any in-flight UI state.
            state.viewMode = true;
            document.body.classList.add('view-mode');
            try { localStorage.setItem('defectLL.viewMode', '1'); } catch (e) {}
            state.pendingImageCell = null;
            clearPasteHighlight();
            if (!preserve) {
                state.cases = [];
                state.loadedIds = new Set();
                state.dirtyIds.clear();
                state.deletedIds.clear();
                state.aiFilterIds = null;
            }
            renderAll();
            updateModeToggleLabel();
            if (idleTimer) { clearTimeout(idleTimer); idleTimer = null; }
            if (reason) setStatus(reason, 'dirty');
            // After re-login, merge with server (preserve mode) or do a clean
            // load (wipe mode).
            openLogin(() => {
                if (preserve && typeof reloadFromServer === 'function') {
                    reloadFromServer().then(() => {
                        if (state.dirtyIds.size + state.deletedIds.size > 0) {
                            setStatus('登入完成,你還有未儲存的變更,請再按一次儲存', 'dirty');
                        }
                    });
                } else {
                    loadData();
                }
            }, { required: true });
        }
        document.getElementById('btnLogout').addEventListener('click', () => {
            if (state.dirtyIds.size + state.deletedIds.size > 0) {
                if (!confirm('還有未儲存的變更,確定要登出?')) return;
            }
            performLogout('已登出');
        });

        // ---- 5-minute inactivity auto-logout ----
        const IDLE_MS = 5 * 60 * 1000;
        let idleTimer = null;
        let lastActivityAt = 0;
        function resetIdleTimer() {
            if (idleTimer) { clearTimeout(idleTimer); idleTimer = null; }
            if (!getAuthUser()) return; // no point counting idle while logged out
            idleTimer = setTimeout(() => {
                // If they have unsaved changes, give them ONE chance to extend.
                if (state.dirtyIds.size + state.deletedIds.size > 0) {
                    if (confirm('閒置 5 分鐘,即將自動登出。\n還有未儲存的變更 — 取消可延長 5 分鐘讓你儲存。')) {
                        // confirm() returns true on OK -> proceed with logout
                    } else {
                        resetIdleTimer();
                        return;
                    }
                }
                performLogout('閒置 5 分鐘,已自動登出');
            }, IDLE_MS);
        }
        function onUserActivity() {
            // Throttle to once per second — mousemove fires thousands of times
            // and we don't need that frequency for "is the user still here".
            const now = Date.now();
            if (now - lastActivityAt < 1000) return;
            lastActivityAt = now;
            resetIdleTimer();
        }
        ['mousemove', 'mousedown', 'keydown', 'click', 'scroll', 'touchstart', 'wheel'].forEach(ev => {
            window.addEventListener(ev, onUserActivity, { passive: true });
        });

        // ---- Login modal ----
        const loginOverlay = document.getElementById('loginOverlay');
        const loginForm = document.getElementById('loginForm');
        const loginUserEl = document.getElementById('loginUser');
        const loginPwdEl = document.getElementById('loginPwd');
        const loginErr = document.getElementById('loginErr');
        let pendingAfterLogin = null;
        // When required=true (page-load gate), hide the cancel button and
        // the "X" close paths so the user can't dismiss the modal without
        // logging in. Used to lock the entire page behind a credential check.
        const loginCancelBtn = document.getElementById('loginCancel');
        const loginTitleEl = document.querySelector('.login-card h3');
        function openLogin(onSuccess, opts) {
            opts = opts || {};
            pendingAfterLogin = onSuccess || null;
            loginErr.classList.remove('show');
            loginErr.textContent = '';
            loginUserEl.value = getAuthUser() || '';
            loginPwdEl.value = '';
            loginCancelBtn.style.display = opts.required ? 'none' : '';
            if (loginTitleEl) loginTitleEl.textContent = opts.required ? '請先登入才能瀏覽' : '進入編輯模式';
            loginOverlay.hidden = false;
            setTimeout(() => (loginUserEl.value ? loginPwdEl : loginUserEl).focus(), 0);
        }
        function closeLogin() {
            loginOverlay.hidden = true;
            pendingAfterLogin = null;
        }
        document.getElementById('loginCancel').addEventListener('click', closeLogin);
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            loginErr.classList.remove('show');
            const username = loginUserEl.value.trim();
            const password = loginPwdEl.value;
            if (!username || !password) return;
            const submitBtn = document.getElementById('loginSubmit');
            submitBtn.disabled = true;
            try {
                const res = await fetch('LineYield.aspx?op=login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify({ username: username, password: password })
                });
                const data = await res.json();
                if (!data.ok) {
                    // Server keeps error codes ASCII-only (encoding-safe);
                    // map to user-facing Chinese here.
                    let msg;
                    if (data.error === 'bad_credentials') msg = '帳號或密碼錯誤';
                    else if (data.error === 'empty_fields') msg = '請輸入帳號與密碼';
                    else msg = data.error || ('登入失敗 (' + res.status + ')');
                    loginErr.textContent = msg;
                    loginErr.classList.add('show');
                    return;
                }
                setAuthUser(data.name || username, data.token, data.role);
                const cb = pendingAfterLogin;
                closeLogin();
                if (cb) cb();
            } catch (err) {
                loginErr.textContent = '網路錯誤: ' + err.message;
                loginErr.classList.add('show');
            } finally {
                submitBtn.disabled = false;
            }
        });

        // ---- View / Edit mode ----
        function enterEditMode() {
            state.viewMode = false;
            document.body.classList.remove('view-mode');
            try { localStorage.setItem('defectLL.viewMode', '0'); } catch (e) {}
            updateModeToggleLabel();
            renderAll();
        }
        function enterViewMode() {
            state.viewMode = true;
            document.body.classList.add('view-mode');
            try { localStorage.setItem('defectLL.viewMode', '1'); } catch (e) {}
            state.pendingImageCell = null;
            clearPasteHighlight();
            // We deliberately keep the sessionStorage authUser here so the
            // user stays logged in for viewing. The "every unlock requires
            // password" rule is enforced separately in the toggle handler,
            // which always opens the login modal when going view -> edit
            // regardless of whether authUser is present.
            updateModeToggleLabel();
            renderAll();
        }
        $('#modeToggle').addEventListener('click', () => {
            if (state.viewMode) {
                // -> edit: ALWAYS prompt for the password again, even if the
                // user is currently logged in for viewing. This is the
                // "每次解鎖都要重輸帳密" rule — view auth is tab-scoped,
                // edit auth is per-unlock.
                openLogin(() => enterEditMode());
                return;
            }
            // -> view: warn if there are unsaved changes
            const pending = state.dirtyIds.size + state.deletedIds.size;
            if (pending > 0) {
                if (!confirm('還有 ' + pending + ' 筆未儲存的變更。\n進入唯讀模式會看不到儲存按鈕,變更仍會留在記憶體裡。要繼續嗎?')) return;
            }
            enterViewMode();
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
                if (sortEl) sortEl.textContent = '';
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
                    const res = await authFetch('LineYield.aspx?op=upsert&ds=' + state.currentDataset, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json; charset=utf-8'
                        },
                        body: JSON.stringify(c)
                    });
                    const data = await res.json();
                    if (!data || !data.ok) {
                        if (data && data.error === 'readonly') throw new Error('你的權限只能閱讀,無法儲存');
                        throw new Error('upsert ' + id + ': ' + (data && data.error || res.status));
                    }
                    state.dirtyIds.delete(id);
                }
                // Deletes
                for (const id of deletedIds) {
                    setStatus('儲存中 ' + (++done) + ' / ' + total + '...');
                    const res = await authFetch('LineYield.aspx?op=delete&id=' + encodeURIComponent(id) + '&ds=' + state.currentDataset, {
                        method: 'POST'
                    });
                    const data = await res.json();
                    if (!data || !data.ok) {
                        if (data && data.error === 'readonly') throw new Error('你的權限只能閱讀,無法儲存');
                        throw new Error('delete ' + id + ': ' + (data && data.error || res.status));
                    }
                    state.deletedIds.delete(id);
                }
                // Re-fetch so any changes made by OTHER users during our session are picked up
                await reloadFromServer({ silent: true });
                markSaved();
            } catch (e) {
                // If the failure was the session-expiry path, the login modal
                // is already up and the dirty rows are still in memory thanks
                // to performLogout's preserveData branch -- guide the user.
                if (/needLogin/i.test(e.message)) {
                    setStatus('登入逾期,請在登入視窗重新登入後再次按儲存', 'error');
                } else {
                    setStatus('儲存失敗: ' + e.message, 'error');
                }
            }
        }

        async function reloadFromServer(opts) {
            opts = opts || {};
            const res = await authFetch('LineYield.aspx?op=list&ds=' + state.currentDataset, { cache: 'no-store' });
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
            updateLastEditDisplay(data._meta);
            renderAll();
        }

        // Render the toolbar "last save" line from the server-stamped _meta.
        // Maps case ids to current [#N] positions and makes them clickable so
        // a reader can jump to whatever the previous save touched.
        function updateLastEditDisplay(meta) {
            const el = document.getElementById('lastEdit');
            if (!el) return;
            if (!meta || !meta.lastEditedAt) {
                el.hidden = true;
                el.innerHTML = '';
                return;
            }
            const when = formatLocalTime(meta.lastEditedAt);
            const who = meta.lastEditedBy || '(未知)';
            const ids = Array.isArray(meta.lastEditedCaseIds) ? meta.lastEditedCaseIds : [];

            // Build chips for any IDs that still exist in the table
            const chips = [];
            ids.forEach(id => {
                const idx = state.cases.findIndex(c => c.id === id);
                if (idx >= 0) chips.push({ n: idx + 1, id: id });
            });

            el.innerHTML = '';
            el.appendChild(document.createTextNode('上次儲存: '));
            const who_el = document.createElement('span');
            who_el.className = 'who';
            who_el.textContent = who;
            el.appendChild(who_el);
            const when_el = document.createElement('span');
            when_el.className = 'when';
            when_el.textContent = ' @ ' + when;
            el.appendChild(when_el);
            if (chips.length > 0) {
                el.appendChild(document.createTextNode(' — 動了'));
                chips.forEach(c => {
                    const chip = document.createElement('span');
                    chip.className = 'ref-chip';
                    chip.textContent = '#' + c.n;
                    chip.title = '點擊跳到此 case';
                    chip.addEventListener('click', () => scrollToCaseByNumber(c.n));
                    el.appendChild(chip);
                });
            } else if (ids.length > 0) {
                el.appendChild(document.createTextNode(' — 動了 ' + ids.length + ' 筆 (已刪除)'));
            }
            el.hidden = false;
        }
        function formatLocalTime(iso) {
            const d = new Date(iso);
            if (isNaN(d.getTime())) return iso;
            const pad = n => (n < 10 ? '0' + n : '' + n);
            return d.getFullYear() + '/' + pad(d.getMonth() + 1) + '/' + pad(d.getDate())
                 + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes());
        }

        window.addEventListener('beforeunload', (e) => {
            if (state.dirtyIds.size > 0 || state.deletedIds.size > 0) {
                e.preventDefault();
                e.returnValue = '有未儲存的變更,確定要離開?';
                return e.returnValue;
            }
        });

        // ---- Load on start ----
        // Gate the very first load behind the login modal so a coworker from
        // another department who lands on the URL can't even see the table.
        // Once they log in for this tab, viewing stays unlocked until the tab
        // is closed; edit mode still re-prompts on every unlock.
        async function loadData() {
            setStatus('載入中...');
            try {
                const res = await authFetch('LineYield.aspx?op=list&ds=' + state.currentDataset, { cache: 'no-store' });
                const data = await res.json();
                state.cases = Array.isArray(data.cases) ? data.cases : [];
                // ensure each has an id
                state.cases.forEach(c => { if (!c.id) c.id = uid(); });
                // Remember which ids exist on disk — used by per-case save & delete logic
                state.loadedIds = new Set(state.cases.map(c => c.id));
                state.dirtyIds.clear();
                state.deletedIds.clear();
                decorateHeaders();
                updateModeToggleLabel();
                updateLastEditDisplay(data._meta);
                renderAll();
            } catch (e) {
                setStatus('載入失敗: ' + e.message, 'error');
            }
        }
        // THEAD starts empty (the static markup got reduced to <tr> with no
        // cells); seed it with the default-dataset schema before bootGate so
        // even the pre-login state has correctly-laid-out headers.
        applyColumnSchema(state.currentDataset);

        (function bootGate() {
            if (getAuthUser()) {
                loadData();
                resetIdleTimer();
                updateModeToggleLabel();
                applyRoleVisibility();
                return;
            }
            setStatus('需要登入');
            openLogin(() => loadData(), { required: true });
        })();

        // ---- View switch (Dashboard / Case Control Table) ----
        // Body class drives visibility (CSS handles the swap).  Default is
        // Dashboard on every fresh load -- we deliberately do NOT remember
        // the previous tab in localStorage, so opening the page always lands
        // on the Dashboard first.
        function setView(name) {
            if (name !== 'light' && name !== 'bulk' && name !== 'dashboard') name = 'dashboard';

            // Switching datasets while there are unsaved changes would silently
            // throw them away on the re-render. Ask once.
            if ((name === 'light' || name === 'bulk') && name !== state.currentDataset) {
                if (state.dirtyIds.size + state.deletedIds.size > 0) {
                    if (!confirm('當前分頁有未儲存的變更,切換會被清掉。確定?')) return;
                }
            }
            document.body.classList.remove('view-dashboard', 'view-light', 'view-bulk');
            document.body.classList.add('view-' + name);
            document.querySelectorAll('.view-tabs button').forEach(b => {
                b.classList.toggle('active', b.getAttribute('data-view') === name);
            });
            if (name === 'light' || name === 'bulk') {
                if (state.currentDataset !== name) {
                    state.currentDataset = name;
                    // Reset per-dataset transient state before pulling fresh rows.
                    state.dirtyIds.clear();
                    state.deletedIds.clear();
                    state.aiFilterIds = null;
                    state.filters = {};
                    state.cases = [];
                    state.loadedIds = new Set();
                    // Reset the COLUMNS + thead to match this dataset, then
                    // pull rows; cell rendering downstream uses COLUMNS, so
                    // schema must be set before renderAll runs.
                    applyColumnSchema(name);
                    if (typeof loadData === 'function') loadData();
                }
            }
        }
        document.querySelectorAll('.view-tabs button').forEach(b => {
            b.addEventListener('click', () => setView(b.getAttribute('data-view')));
        });
        setView('dashboard');

        // ============================================================
        //  AI assistant — floating bubble + chat panel
        // ============================================================
        (function aiInit() {
            const bubble = document.getElementById('aiBubble');
            const panel = document.getElementById('aiPanel');
            const closeBtn = document.getElementById('aiClose');
            const msgs = document.getElementById('aiMessages');
            const input = document.getElementById('aiInput');
            const sendBtn = document.getElementById('aiSend');
            const attachBtn = document.getElementById('aiAttach');
            const fileInput = document.getElementById('aiFile');
            const previewBox = document.getElementById('aiPreview');
            const previewImg = document.getElementById('aiPreviewImg');
            const previewMeta = document.getElementById('aiPreviewMeta');
            const previewRemove = document.getElementById('aiPreviewRemove');
            const newChatBtn = document.getElementById('aiNewChat');
            const sessionListEl = document.getElementById('aiSessionList');
            const titleInput = document.getElementById('aiTitle');
            const tagsRow = document.getElementById('aiTagsRow');

            // ---- Sessions (persisted in localStorage) ----
            const SESSIONS_KEY = 'defectAI.sessions.v1';
            const ACTIVE_KEY = 'defectAI.activeId.v1';
            let sessions = [];
            let activeId = null;
            let busy = false;
            let attachedImage = null; // pending image for the next send

            function loadSessions() {
                try {
                    sessions = JSON.parse(localStorage.getItem(SESSIONS_KEY) || '[]');
                    activeId = localStorage.getItem(ACTIVE_KEY) || null;
                } catch (e) { sessions = []; activeId = null; }
                if (!Array.isArray(sessions)) sessions = [];
                if (sessions.length === 0) {
                    createSession(false); // creates and sets active
                } else if (!sessions.find(s => s.id === activeId)) {
                    activeId = sessions[0].id;
                }
            }
            function saveSessions() {
                try {
                    localStorage.setItem(SESSIONS_KEY, JSON.stringify(sessions));
                    if (activeId) localStorage.setItem(ACTIVE_KEY, activeId);
                } catch (e) { /* quota exceeded — silent fail */ }
            }
            function getActive() { return sessions.find(s => s.id === activeId); }
            function createSession(rerender) {
                const s = {
                    id: 'sess-' + Date.now() + '-' + Math.random().toString(36).slice(2, 6),
                    title: '新對話',
                    tags: [],
                    history: [],
                    createdAt: Date.now(),
                    updatedAt: Date.now()
                };
                sessions.unshift(s);
                activeId = s.id;
                saveSessions();
                if (rerender !== false) {
                    renderSessionList();
                    renderActiveSession();
                    clearAttachment();
                    input.focus();
                }
            }
            function switchSession(id) {
                if (busy) return;
                activeId = id;
                saveSessions();
                renderSessionList();
                renderActiveSession();
                clearAttachment();
            }
            function deleteSession(id) {
                if (busy) return; // would leave in-flight reply orphaned
                const s = sessions.find(x => x.id === id);
                if (!s) return;
                if (!confirm('刪除這個對話?\n「' + (s.title || '新對話') + '」')) return;
                sessions = sessions.filter(x => x.id !== id);
                if (activeId === id) {
                    activeId = sessions.length > 0 ? sessions[0].id : null;
                }
                if (sessions.length === 0) {
                    createSession(false);
                }
                saveSessions();
                renderSessionList();
                renderActiveSession();
            }
            function maybeAutoTitle(s, text) {
                if (s.title === '新對話' && text) {
                    const t = text.replace(/\s+/g, ' ').trim();
                    s.title = t.length > 26 ? t.slice(0, 26) + '...' : t;
                    titleInput.value = s.title;
                }
            }

            function open() {
                panel.hidden = false;
                bubble.classList.add('open');
                updateCaseCount();
                renderSessionList();
                renderActiveSession();
                setTimeout(() => input.focus(), 0);
            }
            // ---- Render: session list, header, tags, messages ----
            function renderSessionList() {
                sessionListEl.innerHTML = '';
                sessions.forEach(s => {
                    const item = document.createElement('div');
                    item.className = 'ai-sess' + (s.id === activeId ? ' active' : '');
                    item.setAttribute('data-id', s.id);
                    const title = document.createElement('div');
                    title.className = 'ai-sess-title';
                    title.textContent = s.title || '新對話';
                    item.appendChild(title);
                    if (s.tags && s.tags.length > 0) {
                        const tagsEl = document.createElement('div');
                        tagsEl.className = 'ai-sess-tags';
                        s.tags.forEach(t => {
                            const tag = document.createElement('span');
                            tag.className = 'tag';
                            tag.textContent = t;
                            tagsEl.appendChild(tag);
                        });
                        item.appendChild(tagsEl);
                    }
                    const del = document.createElement('button');
                    del.type = 'button';
                    del.className = 'ai-sess-del';
                    del.title = '刪除此對話';
                    del.textContent = '×';
                    del.addEventListener('click', (e) => {
                        e.stopPropagation();
                        deleteSession(s.id);
                    });
                    item.appendChild(del);
                    item.addEventListener('click', () => switchSession(s.id));
                    sessionListEl.appendChild(item);
                });
            }
            function renderActiveSession() {
                const s = getActive();
                msgs.innerHTML = '';
                if (!s) return;
                titleInput.value = s.title || '';
                renderActiveTags();
                if (s.history.length === 0) {
                    const n = state.cases.length;
                    appendMessage('assistant',
                        n > 0
                            ? '你好,我已掌握目前頁面上的 ' + n + ' 筆 case 資料,可以根據這些內容回答問題。'
                            : '你好,目前頁面上還沒有 case 資料。請先新增幾筆後再問我。');
                } else {
                    s.history.forEach(m => {
                        if (m.role === 'user') {
                            if (Array.isArray(m.content)) {
                                const t = (m.content.find(p => p.type === 'text') || {}).text || '';
                                const u = (m.content.find(p => p.type === 'image_url') || {}).image_url;
                                appendUserMessage(t, u ? u.url : null);
                            } else {
                                appendUserMessage(m.content, null);
                            }
                        } else if (m.role === 'assistant') {
                            appendMessage('assistant', m.content);
                        }
                    });
                }
            }
            function renderActiveTags() {
                tagsRow.innerHTML = '';
                const s = getActive();
                if (!s) return;
                (s.tags || []).forEach(t => {
                    const chip = document.createElement('span');
                    chip.className = 'ai-tag-chip';
                    chip.textContent = t;
                    const x = document.createElement('button');
                    x.type = 'button';
                    x.className = 'x';
                    x.title = '移除';
                    x.textContent = '×';
                    x.addEventListener('click', () => {
                        s.tags = s.tags.filter(v => v !== t);
                        s.updatedAt = Date.now();
                        saveSessions();
                        renderActiveTags();
                        renderSessionList();
                    });
                    chip.appendChild(x);
                    tagsRow.appendChild(chip);
                });
                const add = document.createElement('button');
                add.type = 'button';
                add.className = 'ai-tag-add';
                add.textContent = '+ 標籤';
                add.addEventListener('click', () => {
                    const raw = prompt('輸入標籤(可用逗號分隔多個):');
                    if (!raw) return;
                    const parts = raw.split(/[,，;；]/).map(x => x.trim()).filter(Boolean);
                    if (parts.length === 0) return;
                    s.tags = s.tags || [];
                    parts.forEach(p => { if (!s.tags.includes(p)) s.tags.push(p); });
                    s.updatedAt = Date.now();
                    saveSessions();
                    renderActiveTags();
                    renderSessionList();
                });
                tagsRow.appendChild(add);
            }
            // Title rename: commit on blur or Enter
            titleInput.addEventListener('blur', () => {
                const s = getActive();
                if (!s) return;
                const v = titleInput.value.trim() || '新對話';
                if (v !== s.title) {
                    s.title = v;
                    s.updatedAt = Date.now();
                    saveSessions();
                    renderSessionList();
                }
            });
            titleInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') { e.preventDefault(); titleInput.blur(); }
            });
            newChatBtn.addEventListener('click', () => {
                if (busy) return; // would leave in-flight reply orphaned
                createSession(true);
            });
            function updateCaseCount() {
                const el = document.getElementById('aiCaseCount');
                if (el) el.textContent = '已載入 ' + state.cases.length + ' 筆 case';
            }
            // Build a compact, text-only snapshot of the cases to feed the LLM.
            // Images are skipped (base64 would explode the prompt); multi-line values
            // are flattened so each case is a tidy block.
            // Trigger keywords that indicate the user wants to add cases.
            // Kept here so both send() and retryForNewCaseBlocks() check the
            // same list.
            const ADD_KEYWORDS = ['加入', '加一筆', '加進', '加到表格', '加上去',
                '新增', '建立', '記錄', '登錄', '填入', '寫進', 'create', 'add'];

            // One-shot retry when the assistant ignored the new-case rule.
            // Re-sends the conversation with an injected, ultra-directive
            // system message that asks it to redo the previous turn as
            // <new-case>...</new-case> blocks only.
            async function retryForNewCaseBlocks(s, ctx) {
                const lightKeys = COLUMNS_LIGHT.filter(c => c.kind !== 'img').map(c => c.key);
                const bulkKeys  = COLUMNS_BULK .filter(c => c.kind !== 'img').map(c => c.key);
                const directive = '你上一次的回應沒有輸出 <new-case> 區塊,違反規則 A。' +
                    '\n請**只輸出 <new-case ds="..."> JSON </new-case> 區塊**,不要任何文字說明、不要前言、不要結語。' +
                    '\n表格圖片就每列一個區塊。讀得到什麼欄位填什麼,讀不到就省略,絕對不可以改寫成文字。' +
                    '\nds="light" 可用 key: ' + lightKeys.join(', ') +
                    '\nds="bulk"  可用 key: ' + bulkKeys.join(', ') +
                    '\n當前分頁: ds="' + state.currentDataset + '"。使用者句子明說的 dataset 才覆寫。' +
                    '\n現在重做上一回應。';
                const messages = [{ role: 'system', content: directive }];
                messages.push(...s.history);
                const typing = appendTyping();
                try {
                    const res = await authFetch('LineYield.aspx?op=chat', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json; charset=utf-8' },
                        body: JSON.stringify({ messages: messages })
                    });
                    const data = await res.json();
                    typing.remove();
                    if (!res.ok || data.ok === false) return; // give up silently
                    const reply = (data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content) || '';
                    if (/<new-case[\s>]/i.test(reply)) {
                        // Replace the prior assistant turn with the retry so
                        // history doesn't keep the failed reply around.
                        if (s.history.length && s.history[s.history.length - 1].role === 'assistant') s.history.pop();
                        s.history.push({ role: 'assistant', content: reply });
                        s.updatedAt = Date.now();
                        saveSessions();
                        appendMessage('assistant', reply);
                    }
                } catch (e) {
                    typing.remove();
                }
            }

            function buildCasesContext() {
                if (!state.cases.length) return '';
                return state.cases.map((c, i) => {
                    const lines = ['[#' + (i + 1) + '] id=' + c.id];
                    COLUMNS.forEach(col => {
                        if (col.kind === 'img') return;
                        const v = c[col.key];
                        if (v == null || v === '') return;
                        if (Array.isArray(v) && v.length === 0) return;
                        const flat = Array.isArray(v)
                            ? v.join(' | ')
                            : String(v).replace(/\r?\n+/g, '; ').trim();
                        if (!flat) return;
                        lines.push('  ' + col.key + ': ' + flat);
                    });
                    return lines.join('\n');
                }).join('\n\n');
            }
            function close() {
                panel.hidden = true;
                bubble.classList.remove('open');
            }
            bubble.addEventListener('click', () => panel.hidden ? open() : close());
            closeBtn.addEventListener('click', close);

            function appendMessage(role, text, cls) {
                const div = document.createElement('div');
                div.className = 'ai-msg ' + (cls || role);
                // For assistant replies: hide raw <new-case> JSON from the bubble
                // and render an inline preview card instead.
                let display = text;
                if (role === 'assistant' && !cls) {
                    display = text.replace(/<new-case(?:\s+ds=["']?\w+["']?)?\s*>[\s\S]*?<\/new-case>/gi, '').trim();
                    if (!display) display = '(已建議新增 case,請看下方卡片)';
                }
                div.textContent = display;
                msgs.appendChild(div);
                if (role === 'assistant' && !cls) {
                    appendCaseRefsToolbar(text);
                    extractNewCases(text).forEach(obj => appendNewCaseCard(obj));
                }
                msgs.scrollTop = msgs.scrollHeight;
                return div;
            }
            // Parse <new-case ds="...">{...}</new-case> blocks. The optional
            // ds="" attribute lets the LLM target a specific dataset (light /
            // bulk) when the user explicitly asks for one; when missing we
            // default to whatever tab the user is currently looking at.
            function extractNewCases(text) {
                const out = [];
                const re = /<new-case(?:\s+ds=["']?(\w+)["']?)?\s*>\s*([\s\S]*?)\s*<\/new-case>/gi;
                let m;
                while ((m = re.exec(text)) !== null) {
                    let ds = (m[1] || '').toLowerCase();
                    if (ds !== 'light' && ds !== 'bulk') ds = state.currentDataset;
                    try {
                        const obj = JSON.parse(m[2]);
                        if (obj && typeof obj === 'object' && !Array.isArray(obj)) {
                            out.push({ ds: ds, obj: obj });
                        }
                    } catch (e) { /* malformed JSON -- skip silently */ }
                }
                return out;
            }
            // Render a "preview + 加入" card for one AI-suggested case.
            function appendNewCaseCard(entry) {
                // Accept both legacy plain-obj entries and the new {ds, obj}
                // tagged entries so older sessions don't break.
                const ds = (entry && entry.ds) ? entry.ds : state.currentDataset;
                const obj = (entry && entry.obj) ? entry.obj : entry;
                const targetCols = (ds === 'bulk' ? COLUMNS_BULK : COLUMNS_LIGHT);
                const editableKeys = targetCols.filter(c => c.kind !== 'img').map(c => c.key);
                const dsLabel = ds === 'bulk' ? '大宗報廢' : '少片數報廢';
                const isCrossDataset = ds !== state.currentDataset;

                const card = document.createElement('div');
                card.className = 'ai-newcase-card';
                const title = document.createElement('div');
                title.className = 'ai-newcase-title';
                title.textContent = 'AI 建議新增 case  →  ' + dsLabel;
                card.appendChild(title);

                const fields = document.createElement('div');
                fields.className = 'ai-newcase-fields';
                let any = false;
                editableKeys.forEach(k => {
                    const v = obj[k];
                    if (v === undefined || v === null || v === '') return;
                    any = true;
                    const row = document.createElement('div');
                    const key = document.createElement('span');
                    key.className = 'ai-newcase-key';
                    key.textContent = k + ':';
                    row.appendChild(key);
                    row.appendChild(document.createTextNode(String(v)));
                    fields.appendChild(row);
                });
                if (!any) {
                    const row = document.createElement('div');
                    row.style.color = 'var(--muted)';
                    row.textContent = '(AI 給的欄位都是空的)';
                    fields.appendChild(row);
                }
                card.appendChild(fields);

                const actions = document.createElement('div');
                actions.className = 'ai-newcase-actions';
                const addBtn = document.createElement('button');
                addBtn.type = 'button';
                addBtn.className = 'ai-newcase-add';
                if (isViewer()) {
                    addBtn.textContent = '無權限編輯';
                    addBtn.disabled = true;
                } else if (isCrossDataset) {
                    addBtn.textContent = '加入到 ' + dsLabel;
                } else {
                    addBtn.textContent = state.viewMode ? '切到編輯並加入' : '加入表格';
                }
                const dismissBtn = document.createElement('button');
                dismissBtn.type = 'button';
                dismissBtn.className = 'ai-newcase-dismiss';
                dismissBtn.textContent = '忽略';
                actions.appendChild(addBtn);
                actions.appendChild(dismissBtn);
                card.appendChild(actions);

                // Same-dataset path: drop into state.cases like before so the
                // user can edit before saving.
                const doAddSameDataset = () => {
                    if (state.viewMode) enterEditMode();
                    const c = { id: uid() };
                    editableKeys.forEach(k => {
                        c[k] = (obj[k] !== undefined && obj[k] !== null) ? String(obj[k]) : '';
                    });
                    state.cases.unshift(c);
                    state.dirtyIds.add(c.id);
                    state.dirty = true;
                    state.filters = {};
                    document.querySelectorAll('#theadRow th[data-col].filtered').forEach(th => th.classList.remove('filtered'));
                    renderAll();
                    setStatus('已加入 1 筆 (記得按儲存)', 'dirty');
                    addBtn.textContent = '✓ 已加入,記得按儲存';
                    addBtn.disabled = true;
                    dismissBtn.style.display = 'none';
                };

                // Cross-dataset path: send the row straight to the target file
                // via the upsert API. The user stays on the current tab; they
                // can flip to the target tab later to see / edit the new row.
                const doAddCrossDataset = async () => {
                    const c = { id: uid() };
                    editableKeys.forEach(k => {
                        c[k] = (obj[k] !== undefined && obj[k] !== null) ? String(obj[k]) : '';
                    });
                    addBtn.disabled = true;
                    addBtn.textContent = '加入中...';
                    try {
                        const res = await authFetch('LineYield.aspx?op=upsert&ds=' + ds, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json; charset=utf-8' },
                            body: JSON.stringify(c)
                        });
                        const data = await res.json();
                        if (data && data.ok) {
                            addBtn.textContent = '✓ 已加入到 ' + dsLabel;
                            dismissBtn.style.display = 'none';
                            setStatus('已加入 1 筆到 ' + dsLabel + '(可切到該分頁查看)', 'saved');
                        } else {
                            addBtn.disabled = false;
                            addBtn.textContent = '加入失敗,再試';
                            const why = (data && data.error) || 'unknown';
                            appendMessage('assistant', '寫入失敗: ' + why, 'error');
                        }
                    } catch (e) {
                        addBtn.disabled = false;
                        addBtn.textContent = '加入失敗,再試';
                        appendMessage('assistant', '網路錯誤: ' + e.message, 'error');
                    }
                };

                addBtn.addEventListener('click', () => {
                    if (isCrossDataset) {
                        if (!getAuthUser()) { openLogin(doAddCrossDataset); return; }
                        doAddCrossDataset();
                    } else {
                        if (state.viewMode && !getAuthUser()) { openLogin(doAddSameDataset); return; }
                        doAddSameDataset();
                    }
                });
                dismissBtn.addEventListener('click', () => card.remove());

                msgs.appendChild(card);
                msgs.scrollTop = msgs.scrollHeight;
            }
            // Extract unique [#N] mentions (only valid indices 1..state.cases.length).
            function extractCaseRefs(text) {
                const seen = new Set();
                const out = [];
                const re = /\[#(\d+)\]/g;
                let m;
                while ((m = re.exec(text)) !== null) {
                    const n = parseInt(m[1], 10);
                    if (n >= 1 && n <= state.cases.length && !seen.has(n)) {
                        seen.add(n);
                        out.push(n);
                    }
                }
                return out;
            }
            function appendCaseRefsToolbar(text) {
                const refs = extractCaseRefs(text);
                if (refs.length === 0) return;
                const bar = document.createElement('div');
                bar.className = 'ai-refs';
                const label = document.createElement('span');
                label.className = 'ai-ref-label';
                label.textContent = '提到 ' + refs.length + ' 筆:';
                bar.appendChild(label);
                refs.forEach(n => {
                    const chip = document.createElement('span');
                    chip.className = 'ai-ref-chip';
                    chip.textContent = '#' + n;
                    chip.title = '點擊跳到此 case';
                    chip.addEventListener('click', () => scrollToCaseByNumber(n));
                    bar.appendChild(chip);
                });
                const applyBtn = document.createElement('button');
                applyBtn.type = 'button';
                applyBtn.className = 'ai-refs-apply';
                applyBtn.textContent = '在表格只顯示這些';
                applyBtn.addEventListener('click', () => applyAiFilter(refs));
                bar.appendChild(applyBtn);
                msgs.appendChild(bar);
            }
            // User message bubble that can show text + an attached image.
            function appendUserMessage(text, imgUrl) {
                const div = document.createElement('div');
                div.className = 'ai-msg user';
                if (text) {
                    const t = document.createElement('div');
                    t.textContent = text;
                    div.appendChild(t);
                }
                if (imgUrl) {
                    const im = document.createElement('img');
                    im.className = 'ai-msg-img';
                    im.src = imgUrl;
                    im.style.cursor = 'zoom-in';
                    im.title = '點擊放大';
                    im.addEventListener('click', () => openOverlay(imgUrl));
                    div.appendChild(im);
                }
                msgs.appendChild(div);
                msgs.scrollTop = msgs.scrollHeight;
                return div;
            }
            // Small inline notice shown after the user bubble when dHash matches
            // an existing case image. Purely UI — not persisted in history.
            function appendHashHintBubble(matches) {
                const refs = matches.map(m => '[#' + m.n + '] (距離 ' + m.dist + ')').join(', ');
                const div = document.createElement('div');
                div.className = 'ai-hash-hint';
                div.textContent = '影像指紋偵測:此圖與 ' + refs + ' 視覺相似';
                msgs.appendChild(div);
                msgs.scrollTop = msgs.scrollHeight;
                return div;
            }
            function appendTyping() {
                const div = document.createElement('div');
                div.className = 'ai-msg typing';
                div.innerHTML = '<span class="dot"></span><span class="dot"></span><span class="dot"></span>';
                msgs.appendChild(div);
                msgs.scrollTop = msgs.scrollHeight;
                return div;
            }

            // ---- Image attachment handling ----
            // Downscale to max 1024px on the longer side and re-encode as JPEG q=0.85.
            // Keeps the request payload reasonable for the LLM and shrinks 4-10x typically.
            function downsizeImage(dataUrl) {
                return new Promise((resolve) => {
                    const img = new Image();
                    img.onload = () => {
                        const MAX = 1024;
                        const longest = Math.max(img.width, img.height);
                        if (longest <= MAX) return resolve(dataUrl);
                        const ratio = MAX / longest;
                        const w = Math.round(img.width * ratio);
                        const h = Math.round(img.height * ratio);
                        const c = document.createElement('canvas');
                        c.width = w; c.height = h;
                        c.getContext('2d').drawImage(img, 0, 0, w, h);
                        try { resolve(c.toDataURL('image/jpeg', 0.85)); }
                        catch (e) { resolve(dataUrl); }
                    };
                    img.onerror = () => resolve(dataUrl);
                    img.src = dataUrl;
                });
            }
            // ---- Perceptual image hashing (dHash) ----
            // Produces a 64-bit hex fingerprint robust to resize / compression /
            // small color shifts. Lets us spot when the uploaded image is the
            // SAME picture as one of the case images, even though the bytes
            // differ (after JPEG re-encode, browser resize, etc).
            const imageHashCache = new Map(); // dataUrl -> hex (16 chars)
            function dhashOf(dataUrl) {
                return new Promise((resolve) => {
                    if (!dataUrl) return resolve(null);
                    if (imageHashCache.has(dataUrl)) return resolve(imageHashCache.get(dataUrl));
                    const img = new Image();
                    img.onload = () => {
                        const W = 9, H = 8;
                        const c = document.createElement('canvas');
                        c.width = W; c.height = H;
                        const ctx = c.getContext('2d');
                        ctx.drawImage(img, 0, 0, W, H);
                        const data = ctx.getImageData(0, 0, W, H).data;
                        // Compare each pixel to its right neighbour -> 8x8 bits.
                        let hex = '';
                        let nibble = 0, count = 0;
                        for (let r = 0; r < H; r++) {
                            for (let col = 0; col < W - 1; col++) {
                                const i1 = (r * W + col) * 4;
                                const i2 = (r * W + col + 1) * 4;
                                const g1 = 0.299 * data[i1] + 0.587 * data[i1 + 1] + 0.114 * data[i1 + 2];
                                const g2 = 0.299 * data[i2] + 0.587 * data[i2 + 1] + 0.114 * data[i2 + 2];
                                nibble = (nibble << 1) | (g2 > g1 ? 1 : 0);
                                count++;
                                if (count === 4) { hex += nibble.toString(16); nibble = 0; count = 0; }
                            }
                        }
                        imageHashCache.set(dataUrl, hex);
                        resolve(hex);
                    };
                    img.onerror = () => resolve(null);
                    img.src = dataUrl;
                });
            }
            function hammingHex(h1, h2) {
                if (!h1 || !h2 || h1.length !== h2.length) return 999;
                let d = 0;
                for (let i = 0; i < h1.length; i++) {
                    let x = parseInt(h1[i], 16) ^ parseInt(h2[i], 16);
                    // popcount over 4 bits
                    while (x) { d += x & 1; x >>= 1; }
                }
                return d;
            }
            // For each case, compute the smallest distance between the uploaded
            // hash and any of its stored images (waferMap + image columns).
            // Returns sorted matches with distance <= threshold.
            async function findImageMatches(uploadedUrl, threshold) {
                const uploaded = await dhashOf(uploadedUrl);
                if (!uploaded) return [];
                const tasks = [];
                state.cases.forEach((c, i) => {
                    const add = (val, field) => {
                        if (Array.isArray(val)) val.forEach(u => { if (u) tasks.push({ idx: i, c: c, field: field, url: u }); });
                        else if (typeof val === 'string' && val) tasks.push({ idx: i, c: c, field: field, url: val });
                    };
                    add(c.waferMap, 'waferMap');
                    add(c.image, 'image');
                });
                const hashes = await Promise.all(tasks.map(t => dhashOf(t.url)));
                const best = new Map(); // c.id -> {n, dist, field}
                tasks.forEach((t, k) => {
                    const h = hashes[k];
                    if (!h) return;
                    const d = hammingHex(uploaded, h);
                    const cur = best.get(t.c.id);
                    if (!cur || d < cur.dist) best.set(t.c.id, { n: t.idx + 1, dist: d, field: t.field });
                });
                const matches = [];
                best.forEach(v => { if (v.dist <= threshold) matches.push(v); });
                matches.sort((a, b) => a.dist - b.dist);
                return matches;
            }
            function approxKB(dataUrl) {
                // base64 -> bytes ratio ≈ 3/4 of base64 length, minus the prefix.
                const i = dataUrl.indexOf(',');
                const b64 = i >= 0 ? dataUrl.slice(i + 1) : dataUrl;
                return Math.round((b64.length * 3 / 4) / 1024);
            }
            function setAttachedFromFile(file) {
                if (!file || !file.type || file.type.indexOf('image/') !== 0) return;
                if (file.size > 20 * 1024 * 1024) {
                    alert('圖片太大(>20MB),請挑小一點的');
                    return;
                }
                const reader = new FileReader();
                reader.onload = async () => {
                    const small = await downsizeImage(reader.result);
                    attachedImage = small;
                    previewImg.src = small;
                    previewMeta.textContent = '已附圖 (' + approxKB(small) + ' KB)';
                    previewBox.hidden = false;
                    input.focus();
                };
                reader.readAsDataURL(file);
            }
            function clearAttachment() {
                attachedImage = null;
                previewBox.hidden = true;
                previewImg.removeAttribute('src');
                previewMeta.textContent = '';
            }
            attachBtn.addEventListener('click', () => fileInput.click());
            fileInput.addEventListener('change', () => {
                const f = fileInput.files && fileInput.files[0];
                fileInput.value = ''; // allow re-picking the same file later
                if (f) setAttachedFromFile(f);
            });
            previewRemove.addEventListener('click', clearAttachment);
            // Click the staged thumbnail to zoom it before sending.
            previewImg.style.cursor = 'zoom-in';
            previewImg.title = '點擊放大';
            previewImg.addEventListener('click', () => {
                if (previewImg.src) openOverlay(previewImg.src);
            });
            // Paste an image directly into the textarea
            input.addEventListener('paste', (ev) => {
                const items = (ev.clipboardData && ev.clipboardData.items) || [];
                for (const it of items) {
                    if (it.kind === 'file' && it.type && it.type.indexOf('image/') === 0) {
                        const blob = it.getAsFile();
                        if (blob) { ev.preventDefault(); setAttachedFromFile(blob); return; }
                    }
                }
            });

            async function send() {
                if (busy) return;
                const text = input.value.trim();
                const img = attachedImage; // snapshot before clearing
                if (!text && !img) return;
                const s = getActive();
                if (!s) return;

                // Build the user turn. With an image we use the OpenAI multimodal
                // content array; text-only stays as a plain string for simplicity.
                let userContent;
                let displayText = text;
                if (img) {
                    if (!displayText) displayText = '請看這張圖,從目前頁面上的 case 中找出最相關的幾筆,並說明判斷依據。';
                    userContent = [
                        { type: 'text', text: displayText },
                        { type: 'image_url', image_url: { url: img } }
                    ];
                } else {
                    userContent = text;
                }

                input.value = '';
                clearAttachment();
                // First user message becomes the auto-title (if user hasn't renamed yet).
                if (s.history.length === 0) maybeAutoTitle(s, displayText);
                appendUserMessage(displayText, img);
                s.history.push({ role: 'user', content: userContent });
                s.updatedAt = Date.now();
                saveSessions();
                renderSessionList();
                busy = true;
                sendBtn.disabled = true;

                // Image fingerprint check: before talking to the LLM, fingerprint
                // the uploaded image and compare against every case's stored
                // images. Hits become a hard hint in the prompt — solves the
                // common "I pasted case#5's map but AI didn't pick #5" problem
                // because the LLM never sees the case images directly.
                let hashMatches = [];
                if (img) {
                    try { hashMatches = await findImageMatches(img, 10); }
                    catch (e) { hashMatches = []; }
                    if (hashMatches.length > 0) appendHashHintBubble(hashMatches);
                }

                const typing = appendTyping();
                try {
                    // Inject the current cases as a system message so the LLM
                    // answers from the user's actual data, not from training.
                    // Rebuilt every turn so freshly-edited cases are visible.
                    const ctx = buildCasesContext();
                    const messages = [];
                    if (ctx) {
                        // Build the column-key lists for BOTH schemas so the LLM
                        // can pick the right one when the user explicitly names
                        // a target dataset ("加入大宗" vs "加入少片數") rather
                        // than always defaulting to whichever tab is currently
                        // open. The add-card UI then renders using the schema
                        // the LLM tagged via the ds= attribute.
                        const lightKeys = COLUMNS_LIGHT.filter(c => c.kind !== 'img').map(c => c.key);
                        const bulkKeys  = COLUMNS_BULK .filter(c => c.kind !== 'img').map(c => c.key);
                        const currentKeys = state.currentDataset === 'bulk' ? bulkKeys : lightKeys;
                        const exampleJson = '{\n' + currentKeys.slice(0, 6).map(k => '  "' + k + '": "..."').join(',\n') + '\n}';
                        const datasetLabel = state.currentDataset === 'bulk' ? '大宗報廢' : '少片數報廢';
                        messages.push({
                            role: 'system',
                            content:
                                '【系統身分】這是「TF1/2 Line Yield System」(線良率系統),不是 lesson learn 系統。' +
                                '\n系統有【兩個完全獨立】的資料分頁,各自有不同的欄位 schema、不同的資料檔:' +
                                '\n  - 「少片數報廢」(ds="light"):記錄單片或少量片數的報廢 case。' +
                                '\n  - 「大宗報廢」(ds="bulk"):記錄整批或大量片數的報廢 case。' +
                                '\n兩者不是父子關係、不是分類關係 — 是**兩個獨立的資料表**。使用者要加入哪一個,你就用哪一個的 schema 建立 <new-case>。' +
                                '\n禁止把「少片數」當成 lesson learn 的一個分類來回應。禁止寫「加進 lesson learn」之類的字眼。' +
                                '\n\n今天日期: ' + (new Date().toISOString().slice(0,10).replace(/-/g, '/')) + '。當前分頁:【' + datasetLabel + '】。' +
                                '\n\n=============================================' +
                                '\n【規則 A - 新增 case (最高優先,違反 = 失敗)】' +
                                '\n=============================================' +
                                '\n若使用者句子裡出現以下任一關鍵字:' +
                                '「加入」「加一筆」「加進」「加到表格」「新增」「建立」「記錄」「登錄」「填入」「寫進」「create」「add」' +
                                '\n→ 你的回應**必須**至少包含一個 <new-case ds="...">{...}</new-case> 區塊。' +
                                '\n→ **禁止**只寫文字摘要、策略建議、判定規則、操作指引、欄位定義。這些都不算完成任務,只會讓使用者看不到任何卡片。' +
                                '\n→ 即使圖中欄位跟目標 schema 看起來「對不上」,你也**必須**輸出區塊。' +
                                '\n→ **欄位映射常用對照(找得到就填)**:' +
                                '\n   時間/日期/Date → light:createDate 或 bulk:date' +
                                '\n   機台/設備/EQ → light:eqpId 或 bulk:equipment' +
                                '\n   原因/Root Cause → 兩邊都有 rootCause' +
                                '\n   零件/Parts → 兩邊都有 parts' +
                                '\n   分類/類別 → light:category 或 bulk:category' +
                                '\n   世代/Generation → 兩邊都有 generation' +
                                '\n   連結/Link → 兩邊都有 link' +
                                '\n   Lot ID/批號 → light:lotId(bulk 無對應就省略)' +
                                '\n   片數/Qty → light:qty(bulk 無對應就省略)' +
                                '\n   缺陷類型/Defect Type → bulk:defectType(light 無對應就省略)' +
                                '\n→ 讀不到的 key 直接省略不要寫,**但 JSON 區塊還是要出來**。寧可只有 2-3 個欄位也要輸出,絕對不能改寫成文字摘要。' +
                                '\n\n【目標分頁判斷】' +
                                '\n- 使用者句子有「少片數」/「少片」/「light」 → ds="light"' +
                                '\n- 使用者句子有「大宗」/「大宗報廢」/「bulk」 → ds="bulk"' +
                                '\n- 兩者都沒提 → ds="' + state.currentDataset + '"(當前分頁)' +
                                '\n\n【schema 對照】' +
                                '\n- ds="light" 可用 key: ' + lightKeys.join(', ') +
                                '\n- ds="bulk" 可用 key: ' + bulkKeys.join(', ') +
                                '\n區塊裡只能用該 ds 列出的 key,跨 schema 的 key 一律不要寫。' +
                                '\n\n【若上傳的是表格/列表/清單圖片】每一列當一筆 case,N 列輸出 N 個區塊,全部用同一個 ds 值。即使來源欄位跟目標 schema 不完全對得上,也要盡量把能對應的欄位填進去(例如表格的「時間」可以填到 light 的 createDate 或 bulk 的 date)。' +
                                '\n\n【範例 - 使用者說「幫我加入少片數case」+ 上傳表格圖】' +
                                '\n回應前面可以一句話確認,然後直接連續輸出區塊:' +
                                '\n好的,以下是從圖中擷取的 N 筆 case:' +
                                '\n<new-case ds="light">' +
                                '\n' + exampleJson +
                                '\n</new-case>' +
                                '\n<new-case ds="light">' +
                                '\n' + exampleJson +
                                '\n</new-case>' +
                                '\n... (N 個)' +
                                '\n\n=============================================' +
                                '\n【規則 B - 引用既有 case】' +
                                '\n=============================================' +
                                '\n引用任何既有 case 時,**必須**使用 [#N] 格式(例如 [#5]、[#12]),不要寫成「case 5」、「第 5 筆」。' +
                                '\n\n=============================================' +
                                '\n【規則 C - 單張圖片(非表格)且使用者沒說要新增】' +
                                '\n=============================================' +
                                '\n描述圖片內容 → 從下面 case 文字欄位推測相關的 [#N] → 依相關度由高到低列出並說明判斷依據。' +
                                '\n\n=============================================' +
                                '\n【目前頁面 case 內容(僅供查詢與比對)】' +
                                '\n=============================================' +
                                '\n' + ctx
                        });
                    }
                    // dHash-detected near-duplicates: tell the LLM in a SEPARATE
                    // system message so it overrides anything else. Distance is
                    // 0-64; <=10 we treat as the same picture.
                    if (hashMatches.length > 0) {
                        const lines = hashMatches.map(m =>
                            '  - [#' + m.n + '] 的 ' + m.field + ' 圖,Hamming 距離 ' + m.dist + ' (0=完全相同)');
                        messages.push({
                            role: 'system',
                            content: '【影像指紋偵測】使用者上傳的圖片,經 dHash 比對,與下列 case 在視覺上幾乎相同:\n' +
                                lines.join('\n') +
                                '\n\n請務必把這些 case 列為「最相關」並排在回覆最前面,並以 [#N] 格式引用。'
                        });
                    }
                    messages.push(...s.history);
                    const res = await authFetch('LineYield.aspx?op=chat', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json; charset=utf-8' },
                        body: JSON.stringify({ messages: messages })
                    });
                    const data = await res.json();
                    typing.remove();
                    if (!res.ok || data.ok === false) {
                        // Translate server-side error codes into Chinese the
                        // user can act on. "needLogin" specifically does NOT
                        // mean "you lack edit role" -- it means the session
                        // token was lost (e.g. IIS recycled) and the user
                        // needs to authenticate again.
                        let msg;
                        if (data && data.error === 'needLogin') {
                            msg = 'Session 已過期,請重新登入後再試一次';
                        } else if (data && data.error === 'readonly') {
                            msg = '您的帳號沒有編輯權限,無法執行此操作';
                        } else {
                            msg = (data && (data.error || data.detail)) || ('HTTP ' + res.status);
                        }
                        appendMessage('assistant', '錯誤: ' + msg, 'error');
                        // Drop the failed user turn so the next attempt starts clean
                        s.history.pop();
                        saveSessions();
                        return;
                    }
                    // Standard OpenAI-format response
                    const reply = (data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content) || '(空回應)';
                    appendMessage('assistant', reply);
                    s.history.push({ role: 'assistant', content: reply });
                    s.updatedAt = Date.now();
                    saveSessions();

                    // Self-correction fallback: if the user message clearly
                    // asked to add cases (keywords present) but the LLM
                    // returned ZERO <new-case> blocks, ask once more with
                    // a sharper directive. One-shot only -- the retry sets
                    // attemptedRetry on the session so we don't loop.
                    const userWantsAdd = ADD_KEYWORDS.some(k => displayText.indexOf(k) >= 0);
                    const replyHasBlocks = /<new-case[\s>]/i.test(reply);
                    if (userWantsAdd && !replyHasBlocks && !s._retriedNewCase) {
                        s._retriedNewCase = true;
                        try { await retryForNewCaseBlocks(s, ctx); }
                        finally { s._retriedNewCase = false; }
                    }
                } catch (e) {
                    typing.remove();
                    appendMessage('assistant', '網路錯誤: ' + e.message, 'error');
                    s.history.pop();
                    saveSessions();
                } finally {
                    busy = false;
                    sendBtn.disabled = false;
                    input.focus();
                }
            }
            sendBtn.addEventListener('click', send);
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    send();
                }
            });

            // ---- Boot: load saved sessions, populate sidebar+title now so
            //          the first open() has no flicker. Title text is set
            //          when the user opens the panel via renderActiveSession().
            loadSessions();
            renderSessionList();
        })();
    </script>
</body>
</html>
