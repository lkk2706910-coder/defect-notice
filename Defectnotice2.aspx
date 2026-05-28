<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Defectnotice2.aspx.cs" Inherits="GPTPoCDB_SampleSite_NotesTable" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Defect Notice</title>
    <style>
        :root {
            --bg: #0b1220;
            --panel: #0f1b33;
            --text: #e7eefc;
            --muted: #a9b7d6;
            --border: rgba(255,255,255,0.12);
            --header: rgba(255,255,255,0.06);
            --rowHover: rgba(99, 179, 237, 0.10);
            --chip: rgba(99, 179, 237, 0.18);
        }

        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, "Noto Sans", "Helvetica Neue", sans-serif;
            background: radial-gradient(1200px 600px at 20% 0%, #152a52 0%, var(--bg) 60%);
            color: var(--text);
        }

        .container {
            max-width: 1280px;
            margin: 24px auto;
            padding: 0 16px;
        }

        .card {
            background: linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.03));
            border: 1px solid var(--border);
            border-radius: 14px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.35);
            overflow: hidden;
        }

        .card-header {
            padding: 18px 18px 10px 18px;
            border-bottom: 1px solid var(--border);
            background: rgba(255,255,255,0.03);
        }

        .title {
            font-size: 18px;
            font-weight: 700;
            margin: 0;
        }

        .subtitle {
            margin-top: 6px;
            font-size: 12px;
            color: var(--muted);
        }

                .notice {
            margin-top: 10px;
            border: 1px solid rgba(255, 209, 102, 0.35);
            background: rgba(255, 209, 102, 0.10);
            border-radius: 12px;
            padding: 10px 12px;
        }

        .notice-title {
            font-weight: 800;
            font-size: 12px;
            letter-spacing: .02em;
            color: #ffd166;
            margin-bottom: 8px;
        }

        /* notice table (like screenshot) */
        table.notice-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }

        table.notice-table th,
        table.notice-table td {
            padding: 8px 10px;
            border-top: 1px solid rgba(255,255,255,0.10);
        }

        table.notice-table th {
            text-align: left;
            color: var(--muted);
            font-weight: 900;
            letter-spacing: .02em;
            white-space: nowrap;
        }

        table.notice-table td.num {
            width: 56px;
            text-align: right;
            color: var(--muted);
            font-weight: 800;
        }

        a.notice-link {
            color: var(--text);
            text-decoration: underline;
            font-weight: 800;
        }


        .card-body {
            padding: 14px 18px 18px 18px;
        }

        .toolbar {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 12px;
        }

        /* 單一膠囊列：把所有功能包在同一組 */
        .toolbar-compact {
            justify-content: flex-start;
            gap: 10px;
        }

        .pill {
            display: inline-flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 0;
            border: 1px solid var(--border);
            border-radius: 999px;
            overflow: hidden;
            background: rgba(255,255,255,0.03);
        }

        .pill .chip {
            border: none;
            border-right: 1px solid var(--border);
            border-radius: 0;
            background: transparent;
        }

        .pill .chip:last-child { border-right: none; }

        /* 三群膠囊 */
        .pill-row { display: flex; flex-wrap: wrap; gap: 10px; }
        .pill-row .pill { margin: 0; }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            background: var(--chip);
            border: 1px solid var(--border);
            color: var(--text);
            font-size: 12px;
            user-select: none;
        }

        .chip input[type='checkbox'],
        .chip input[type='radio'] {
            accent-color: #63b3ed;
            width: 14px;
            height: 14px;
        }

                /* 四區塊版面（不左右捲動） */
        .sections {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        @media (max-width: 1100px) {
            .sections { grid-template-columns: 1fr; }
        }

        /* ===== Table mode (like screenshot) ===== */
        .sections.table-mode {
            display: block;
        }

        .sections.table-mode .section {
            margin-bottom: 12px;
        }

        .dn-table-wrap { overflow: auto; }

                table.dn-table {
            width: 100%;
            min-width: 1180px;
            border-collapse: collapse;
            font-size: 12px;
            table-layout: fixed;
        }


        table.dn-table th,
        table.dn-table td {
            padding: 8px;
            border-bottom: 1px solid rgba(255,255,255,0.10);
            vertical-align: top;
        }

        table.dn-table thead th {
            position: sticky;
            top: 0;
            z-index: 3;
            background: rgba(10, 18, 32, 0.95);
            color: var(--muted);
            font-weight: 900;
            letter-spacing: .02em;
            text-align: left;
            white-space: nowrap;
        }

        table.dn-table tbody tr:hover td {
            background: rgba(99, 179, 237, 0.08);
        }

        .dn-title-cell a {
            color: #93c5fd;
            text-decoration: underline;
            font-weight: 800;
        }

        .dn-title-cell .dn-dd {
            margin-top: 6px;
            color: var(--muted);
            font-size: 12px;
        }

        .dn-eqpid-cell {
            white-space: pre-line;
            line-height: 1.2;
        }

                .dn-img {
            width: 60px;
            height: 60px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.14);
            background: rgba(255,255,255,0.05);
            object-fit: cover;
            display: block;
        }


        .dn-img.dn-map { border-radius: 999px; }

        /* map should keep circular shape (no stretching) */
        .dn-img.dn-map {
            object-fit: contain;
            background: rgba(255,255,255,0.03);
        }


        


        .section {
            border: 1px solid var(--border);
            border-radius: 12px;
            background: rgba(5, 10, 20, 0.30);
            overflow: hidden;
        }

        .section-title {
            padding: 10px 12px;
            font-weight: 800;
            letter-spacing: .02em;
            background: rgba(255,255,255,0.04);
            border-bottom: 1px solid var(--border);
        }

        /* Search bar inside right-side section title */
        .section-title.has-search {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .section-title .title-right { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }

        .section-title .title-right label.search-label {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-left: 6px;
        }

        .section-title .title-right input[type='text'] {
            width: 120px;
            background: transparent;
            border: 1px solid rgba(255,255,255,0.14);
            border-radius: 10px;
            padding: 6px 8px;
            outline: none;
            color: var(--text);
            font-size: 12px;
        }

        .section-title .title-right .search-label { color: var(--muted); font-size: 12px; font-weight: 700; }

        /* weekly table: sticky EQPID column */
        #weeklySection table { border-collapse: separate; border-spacing: 0; }
        #weeklySection .sticky-col {
            position: sticky;
            left: 0;
            z-index: 2;
            background: rgba(5, 10, 20, 0.92);
        }
        #weeklySection th.sticky-col { z-index: 3; }

        .section-count { color: var(--muted); font-weight: 600; margin-left: 6px; font-size: 12px; }

        .item {
            padding: 10px 12px;
            border-bottom: 1px solid var(--border);
        }
        .item:last-child { border-bottom: none; }

        /* new： [Title] / [Date] / [Open] / [EQPID] */
        .item-collapsed {
            display: grid;
            grid-template-columns: minmax(240px, 1fr) 120px 70px minmax(320px, 1fr);
            align-items: center;
            gap: 16px;
        }

        /* EQPID 若是空值時也要占位，避免看起來像消失 */
        .item-collapsed .eqpid:empty::after {
            content: "-";
            color: rgba(169,183,214,0.6);
        }

        /* 近一個月內重複 EQPID 標色 */
        .eqpid-dup {
            color: #ffd166;
            font-weight: 800;
        }

        /* 週表子列數字 >=3 變紅（會跟著 FAB 切換，JS 會動態加/移除） */
        .hot {
            color: #ff5d5d;
            font-weight: 900;
        }

        .item-collapsed .title {
            font-weight: 800;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .item-collapsed .date {
            justify-self: start;
            color: var(--muted);
            font-size: 12px;
            border: 1px solid var(--border);
            padding: 4px 8px;
            border-radius: 999px;
            white-space: nowrap;
        }

        .item-collapsed .doc { justify-self: start; }

        /* Open：純文字大小 */
        .item-collapsed .doc a.btn {
            padding: 0;
            margin: 0;
            background: transparent;
            border: none;
            box-shadow: none;
            font-size: 12px;
            line-height: 1;
        }
        .item-collapsed .doc a.btn:hover { text-decoration: underline; }

        .item-collapsed .eqpid {
            justify-self: start;
            text-align: left;
            white-space: normal;
            overflow: visible;
            text-overflow: clip;
            line-height: 1.25;
            min-width: 320px;
        }

        .item-collapsed .eqpid .tag {
            border: none;
            background: transparent;
            padding: 0;
        }

        .item-detail { display: none; margin-top: 10px; }
        .item.expanded .item-detail { display: block; }

        @media (max-width: 1100px) {
            .item-collapsed {
                grid-template-columns: 1fr;
                align-items: start;
            }
            .item-collapsed .date,
            .item-collapsed .doc { justify-self: start; }
        }

        .item-head {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            align-items: flex-start;
            margin-bottom: 8px;
        }

        .item-title {
            font-weight: 750;
            line-height: 1.25;
            word-break: break-word;
        }

        .item-meta { display: flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; }

        .tag {
            font-size: 12px;
            padding: 4px 8px;
            border-radius: 999px;
            border: 1px solid var(--border);
            background: rgba(255,255,255,0.03);
            max-width: 100%;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .kv {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 6px 10px;
        }

        .kv-row {
            display: grid;
            grid-template-columns: 110px minmax(0, 1fr);
            gap: 8px;
            align-items: start;
        }

        .k { color: var(--muted); font-size: 12px; }
        .v { color: var(--text); font-size: 12px; word-break: break-word; }

        .actions { margin-top: 10px; }
        .btn {
            display: inline-block;
            font-size: 12px;
            padding: 6px 10px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: rgba(99, 179, 237, 0.16);
            color: var(--text);
            text-decoration: none;
        }
        .btn:hover { background: rgba(99, 179, 237, 0.26); }

        .muted { color: var(--muted); }

        /* performance table */
        .perf-table { width:100%; border-collapse:collapse; font-size:12px; }
        .perf-table th, .perf-table td { padding:8px; border-bottom:1px solid rgba(255,255,255,0.10); }
        .perf-table th { text-align:left; color: var(--muted); font-weight:800; letter-spacing:.02em; }
        .perf-table td.num, .perf-table th.num { text-align:right; }
        .perf-table tr:hover td { background: rgba(99, 179, 237, 0.08); }
        .perf-tool { text-decoration: underline; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="card-header">
                <h1 class="title">Defect notice 每日看版</h1>
                <div class="subtitle">依 EQPID 篩選 + DataDate 範圍；結果依 EQPTYPE 分群顯示（重複資料會全部列出）</div>

                <!-- 置頂公告（後端會填入內容） -->
                <asp:PlaceHolder ID="phNotice" runat="server"></asp:PlaceHolder>
            </div>
            <div class="card-body">
                <div class="toolbar toolbar-compact">
                    <div class="pill-row">
                        <div class="pill">
                            <span class="chip">FAB:</span>
                            <label class="chip"><input type="radio" name="fab" class="fab" value="ALL" checked /> ALL</label>
                            <label class="chip"><input type="radio" name="fab" class="fab" value="P14" /> P14</label>
                            <label class="chip"><input type="radio" name="fab" class="fab" value="P56" /> P56</label>
                        </div>

                        <div class="pill">
                            <span class="chip">Tool:</span>
                            <button type="button" class="btn jump" data-toolprefix="ULKCVD-" style="margin:6px 6px;">ULKCVD</button>
                            <button type="button" class="btn jump" data-toolprefix="TEOSPE-" style="margin:6px 6px;">TEOSPE</button>
                            <button type="button" class="btn jump" data-toolprefix="APF-" style="margin:6px 6px;">APF</button>
                            <button type="button" class="btn jump" data-toolprefix="BLOKCVD-" style="margin:6px 6px;">BLOKCVD</button>
                            <button type="button" class="btn jump" data-toolprefix="NISACVD-" style="margin:6px 6px;">NISACVD</button>
                            <button type="button" class="btn jump" data-toolprefix="SACVD-" style="margin:6px 6px;">SACVD</button>
                        </div>

                        <div class="pill">
                            <button type="button" id="btnReset" class="btn" style="margin:6px 8px;">回復設定</button>
                        </div>

                        <div class="pill" style="opacity:.0; pointer-events:none; width:0; overflow:hidden;"></div>

                    </div>
                </div>



                <div class="layout1 sections" id="layout1">
                    <asp:PlaceHolder ID="phTable" runat="server"></asp:PlaceHolder>
                </div>

                <div class="layout2" id="layout2" style="display:none;">
                    <div id="layout2Counts"></div>
                    <div id="layout2Sections" class="sections"></div>
                </div>

                <script>
                    // (Charts removed)

                                        // range filter removed
                    function getRangeStartDate() { return null; }

                                        function getJumpPrefix() {
                        return (document.getElementById('qEqp')?.value || '').trim();
                    }

                    function setNoticeVisibilityByTool() {
                        // notice always visible; but rows inside will be filtered by qEqp
                        const notice = document.querySelector('.notice');
                        if (notice) notice.style.display = '';
                    }



                    function getFabValue() {
                        const r = document.querySelector('input.fab:checked');
                        return r ? r.value : 'ALL';
                    }


                    function getRangeMonthsSet() {
                        // charts removed -> month table range filter not supported
                        return null;
                    }


                    let activeSubEqpid = null; // e.g. ULKCVD-04

                    

                                                            function applyCardFilter() {
                                                                const fab = getFabValue();
                                                                const qLot = (document.getElementById('qLot')?.value || '').trim().toLowerCase();
                                                                const qEqp = (document.getElementById('qEqp')?.value || '').trim().toLowerCase();

                                                                // always show all sections
                                                                document.querySelectorAll('.sections > [data-section]').forEach(sectionEl => { sectionEl.style.display = ''; });

                                                                // Table mode: rows are <tr class='dn-row item'>
                                                                document.querySelectorAll('tr.item[data-sub-eqpid]').forEach(item => {
                                                                    const isP56 = item.getAttribute('data-is-p56') === '1';
                                                                    if (fab === 'P56' && !isP56) { item.style.display = 'none'; return; }
                                                                    if (fab === 'P14' && isP56) { item.style.display = 'none'; return; }

                                                                    if (qLot) {
                                                                        const lot = (item.getAttribute('data-lotid') || '').toLowerCase();
                                                                        if (!lot.includes(qLot)) { item.style.display = 'none'; return; }
                                                                    }
                                                                    if (qEqp) {
                                                                        const eqp = (item.getAttribute('data-eqpid') || '').toLowerCase();
                                                                        if (!eqp.includes(qEqp)) { item.style.display = 'none'; return; }
                                                                    }

                                                                    item.style.display = '';
                                                                });

                                                                // Notice table: only filtered by Tool buttons (prefix), not by clicking notice rows
                                                                const qEqpRaw = (document.getElementById('qEqp')?.value || '').trim().toLowerCase();
                                                                const toolPrefix = qEqpRaw.endsWith('-') ? qEqpRaw : '';
                                                                const fabMode = getFabValue();

                                                                document.querySelectorAll('a.notice-link[data-tool]').forEach(a => {
                                                                    const t = (a.getAttribute('data-tool') || '').toLowerCase();
                                                                    const tr = a.closest('tr');
                                                                    if (!tr) return;

                                                                    // tool filter from Tool buttons
                                                                    if (toolPrefix && !t.startsWith(toolPrefix)) { tr.style.display = 'none'; return; }

                                                                    // FAB filter: P56 only show *-Bxx, P14 hide *-Bxx, ALL show all
                                                                    const isB = t.indexOf('-b') >= 0;
                                                                    if (fabMode === 'P56' && !isB) { tr.style.display = 'none'; return; }
                                                                    if (fabMode === 'P14' && isB) { tr.style.display = 'none'; return; }

                                                                    tr.style.display = '';
                                                                });




                                                                // highlight active Jump button
                                                                document.querySelectorAll('button.jump[data-toolprefix]').forEach(b => {
                                                                    const p = (b.getAttribute('data-toolprefix') || '');
                                                                    const active = qEqp && p && qEqp.toLowerCase() === p.toLowerCase();
                                                                    b.style.outline = active ? '2px solid rgba(99,179,237,0.65)' : '';
                                                                });

                                                                setNoticeVisibilityByTool();
                                                            }





                    function setActiveSubEqpid(sub) {
                        activeSubEqpid = sub;
                        document.querySelectorAll('#countsTable tr.child-row').forEach(tr => {
                            tr.style.outline = (tr.getAttribute('data-sub-eqpid') === sub) ? '2px solid rgba(99,179,237,0.55)' : '';
                        });
                    }






                                        function syncVisibility() {
                        // only FAB filter + search inputs
                        applyCardFilter();
                    }


                                        function wireCardToggle() {
                        // legacy card mode only (table mode doesn't have .item-collapsed)
                        document.querySelectorAll('.item .item-collapsed').forEach(el => {
                            el.addEventListener('click', (ev) => {
                                // 點 Open DOCURL 不要觸發展開/收合
                                const a = ev.target && ev.target.closest ? ev.target.closest('a') : null;
                                if (a) return;

                                const item = el.closest('.item');
                                if (!item) return;
                                item.classList.toggle('expanded');
                            });
                        });
                    }

                    // ===== Table mode filters (like screenshot) =====
                    


                                        document.querySelectorAll('input.fab').forEach(rb => rb.addEventListener('change', syncVisibility));



                    // Counts Month/Week 會有兩份（month表/ week表），用事件委派避免漏綁
                    document.addEventListener('change', (ev) => {
                        const t = ev.target;
                        if (t && t.classList && t.classList.contains('countgrain')) {
                            syncVisibility();
                        }
                    });


                                        // Search：打字即時觸發過濾
                    const qLotEl = document.getElementById('qLot');
                    const qEqpEl = document.getElementById('qEqp');
                    if (qLotEl) qLotEl.addEventListener('input', syncVisibility);
                    if (qEqpEl) qEqpEl.addEventListener('input', syncVisibility);

                    // initial notice visibility
                    setNoticeVisibilityByTool();


                                        // 置頂公告點擊：只影響下方資料表（不改變置頂清單的顯示）
                                        document.addEventListener('click', (ev) => {
                                            const a = ev.target && ev.target.closest ? ev.target.closest('a.notice-link[data-tool]') : null;
                                            if (!a) return;
                                            const tool = a.getAttribute('data-tool') || '';

                                            activeSubEqpid = null;

                                            const input = document.getElementById('qEqp');
                                            if (input) {
                                                const cur = (input.value || '').trim();
                                                if (cur.toLowerCase() === tool.toLowerCase()) input.value = '';
                                                else input.value = tool;
                                            }

                                            // only refresh bottom table; keep notice list as-is
                                            applyCardFilter();
                                        });


                                        // Jump buttons: click to filter by tool prefix (e.g. TEOSPE-)
                                        document.addEventListener('click', (ev) => {
                                            const btn = ev.target && ev.target.closest ? ev.target.closest('button.jump[data-toolprefix]') : null;
                                            if (!btn) return;
                                            const p = (btn.getAttribute('data-toolprefix') || '').trim();
                                            const input = document.getElementById('qEqp');
                                            if (!input) return;

                                            // toggle
                                            const cur = (input.value || '').trim();
                                            if (cur.toLowerCase() === p.toLowerCase()) input.value = '';
                                            else input.value = p;

                                            activeSubEqpid = null;
                                            syncVisibility();
                                        });




                                        // reset filters to initial defaults
                                        document.getElementById('btnReset')?.addEventListener('click', () => {
                                            // FAB default = ALL
                                            document.querySelectorAll('input.fab').forEach(rb => { rb.checked = (rb.value === 'ALL'); });

                                            // clear search
                                            const qLotEl = document.getElementById('qLot');
                                            const qEqpEl = document.getElementById('qEqp');
                                            if (qLotEl) qLotEl.value = '';
                                            if (qEqpEl) qEqpEl.value = '';

                                            activeSubEqpid = null;

                                            syncVisibility();
                                        });





                    


                                        // table-mode layout (like screenshot)
                    document.getElementById('layout1')?.classList.add('table-mode');

                    wireCardToggle();
                    syncVisibility();

                </script>
            </div>
        </div>
    </div>
</body>
</html>
