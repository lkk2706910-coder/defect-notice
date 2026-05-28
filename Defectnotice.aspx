<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Defectnotice.aspx.cs" Inherits="GPTPoCDB_SampleSite_NotesTable" %>

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
            margin-bottom: 6px;
        }

        .notice-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .notice-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid rgba(255, 209, 102, 0.35);
            background: rgba(255, 209, 102, 0.12);
            color: var(--text);
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
        }

        .notice-chip:hover { background: rgba(255, 209, 102, 0.18); }

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
                <h1 class="title">Defect Notice</h1>
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
                            <span class="chip">EQPID:</span>
                            <label class="chip"><input type="checkbox" class="eqpid" value="NISACVD" checked /> NISACVD</label>
                            <label class="chip"><input type="checkbox" class="eqpid" value="SACVD" checked /> SACVD</label>
                        </div>

                        <div class="pill">
                            <span class="chip">Range:</span>
                            <label class="chip"><input type="radio" name="range" class="range" value="30" checked /> 30D</label>
                            <label class="chip"><input type="radio" name="range" class="range" value="60" /> 60D</label>
                            <label class="chip"><input type="radio" name="range" class="range" value="90" /> 90D</label>
                            <label class="chip"><input type="radio" name="range" class="range" value="180" /> 180D</label>
                            <label class="chip"><input type="radio" name="range" class="range" value="all" /> ALL</label>
                        </div>

                        <div class="pill" style="opacity:.0; pointer-events:none; width:0; overflow:hidden;"></div>

                        <div class="pill">
                            <span class="chip">Chart:</span>
                            <label class="chip"><input type="radio" name="charttype" class="charttype" value="bar" checked /> Bar</label>
                            <label class="chip"><input type="radio" name="charttype" class="charttype" value="pie" /> Pie</label>
                        </div>

                        <div class="pill">
                            <button type="button" id="btnPerf" class="btn" style="margin:6px 8px;">Performance</button>
                            <button type="button" id="btnLayout" class="btn" style="margin:6px 8px;">版面二</button>
                            <button type="button" id="btnReset" class="btn" style="margin:6px 8px;">回復設定</button>
                        </div>
                    </div>
                </div>

                <div class="section" style="margin-bottom:12px;">
                    <div class="section-title">Trend (count by DataDate)</div>
                    <div style="padding:10px 12px;">
                        <canvas id="trendChart" height="160"></canvas>
                    </div>
                </div>

                <div class="section" id="trendPieSection" style="margin-bottom:12px; display:none;">
                    <div class="section-title">Tool distribution (pie, per section)</div>
                    <div style="padding:10px 12px; display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:12px;">
                        <div class="section" style="margin:0;">
                            <div class="section-title" id="pie_title_NISACVD">NISACVD</div>
                            <div style="padding:10px 12px; height:260px;"><canvas id="pie_NISACVD"></canvas></div>
                        </div>
                        <div class="section" style="margin:0;">
                            <div class="section-title" id="pie_title_SACVD">SACVD</div>
                            <div style="padding:10px 12px; height:260px;"><canvas id="pie_SACVD"></canvas></div>
                        </div>
                    </div>
                </div>

                <div class="section" style="margin-bottom:12px;">
                    <div class="section-title">Trend (count by EQPID, grouped by week)</div>
                    <div style="padding:10px 12px;">
                        <canvas id="eqWeekChart" height="180"></canvas>
                    </div>
                </div>

                <div class="section" id="perfSection" style="margin-bottom:12px; display:none;">
                    <div class="section-title">Performance (by tool in selected range)</div>
                    <div style="padding:10px 12px; overflow:auto;">
                        <table class="perf-table" id="perfTable">
                            <thead>
                                <tr>
                                    <th>EQPID</th>
                                    <th class="num">Count</th>
                                    <th class="num">Share</th>
                                    <th class="num">Latest</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                        <div class="muted" id="perfHint" style="margin-top:8px; font-size:12px;">Click EQPID to filter cards (same as search).</div>
                    </div>
                </div>

                <div class="layout1 sections" id="layout1">
                    <asp:PlaceHolder ID="phTable" runat="server"></asp:PlaceHolder>
                </div>

                <div class="layout2" id="layout2" style="display:none;">
                    <div id="layout2Counts"></div>
                    <div id="layout2Sections" class="sections"></div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
                <script>
                    // quick sanity log
                    try { console.log('Defectnotice JS start', new Date().toISOString()); } catch (e) { }

                    // chartData / tool performance / eq-week chart 由後端塞入 window.__trendData / window.__perfRows / window.__eqChartRows
                    // 新格式：seriesAll/seriesP14/seriesP56；舊格式：series
                    const trend = window.__trendData || { labels: [], series: { NISACVD: [], SACVD: [] } };
                    try { console.log('trend labels', (trend.labels||[]).length, 'perfRows', (window.__perfRows||[]).length, 'eqChartRows', (window.__eqChartRows||[]).length); } catch (e) { }
                    const perfRows = window.__perfRows || []; // [{d:'yyyy-MM-dd', sec:'NISACVD', tool:'NISACVD-04', isP56:0/1}]
                    const eqChartRows = window.__eqChartRows || []; // [{wk:'2026W08', sec:'NISACVD', tool:'NISACVD-04', toolShort:'N-04', isP56:0/1}]

                    const ctx = document.getElementById('trendChart');
                    const ctxEq = document.getElementById('eqWeekChart');
                    if (!ctx || !ctxEq) { try { console.error('canvas missing', {trendChart:!!ctx, eqWeekChart:!!ctxEq}); } catch (e) {} }
                    const colors = {
                        NISACVD: 'rgba(255, 159, 64, 0.9)',
                        SACVD: 'rgba(54, 162, 235, 0.9)'
                    };

                    const makeDataset = (k) => ({
                        label: k,
                        data: (getSeriesByFab()[k] || []),
                        borderColor: colors[k],
                        backgroundColor: colors[k],
                        tension: 0.25,
                        pointRadius: 1,
                        borderWidth: 2
                    });

                    let chartType = 'bar';
                    const chart = new Chart(ctx, {
                        type: chartType,
                        data: {
                            labels: trend.labels,
                            datasets: ['NISACVD', 'SACVD'].map(makeDataset)
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { labels: { color: '#e7eefc' } },
                                tooltip: { mode: 'index', intersect: false }
                            },
                            interaction: { mode: 'index', intersect: false },
                            scales: {
                                x: { ticks: { color: '#a9b7d6', maxRotation: 0, autoSkip: true }, grid: { color: 'rgba(255,255,255,0.08)' } },
                                y: {
                                    type: 'logarithmic',
                                    ticks: {
                                        color: '#a9b7d6',
                                        callback: (v) => (v === 1 ? '1' : (v % 10 === 0 ? v : ''))
                                    },
                                    grid: { color: 'rgba(255,255,255,0.08)' },
                                    beginAtZero: false
                                }
                            }
                        }
                    });

                    // ===== EQPID x Week chart (X=tool, legend=week) =====
                    const eqWeekChart = new Chart(ctxEq, {
                        type: 'bar',
                        data: { labels: [], datasets: [] },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { labels: { color: '#e7eefc' } },
                                tooltip: { mode: 'index', intersect: false }
                            },
                            interaction: { mode: 'index', intersect: false },
                            scales: {
                                x: { ticks: { color: '#a9b7d6', maxRotation: 0, autoSkip: true }, grid: { color: 'rgba(255,255,255,0.08)' } },
                                y: { ticks: { color: '#a9b7d6' }, grid: { color: 'rgba(255,255,255,0.08)' }, beginAtZero: true }
                            }
                        }
                    });

                    function toIsoWeekString(date) {
                        const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
                        const dayNum = d.getUTCDay() || 7;
                        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
                        const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
                        const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
                        const yyyy = d.getUTCFullYear();
                        return `${yyyy}W${String(weekNo).padStart(2, '0')}`;
                    }

                    function getRangeIsoWeeksSet() {
                        const rv = getRangeValue();
                        if (rv === 'all') return null;

                        const days = parseInt(rv, 10);
                        const n = isNaN(days) ? trend.labels.length : days;
                        const start = Math.max(0, trend.labels.length - n);
                        const labels = trend.labels.slice(start);

                        const set = new Set();
                        labels.forEach(s => {
                            if (!s) return;
                            const d = new Date(s + 'T00:00:00');
                            set.add(toIsoWeekString(d));
                        });
                        return set;
                    }

                    function renderEqWeekChart() {
                        const selected = new Set([...document.querySelectorAll('input.eqpid:checked')].map(x => x.value));
                        const fab = getFabValue();
                        const weekSet = getRangeIsoWeeksSet();

                        // wk -> tool -> count
                        const map = new Map();
                        const weeks = new Set();
                        const toolsTotal = new Map();

                        for (const r of eqChartRows) {
                            if (!r) continue;
                            if (!selected.has(r.sec)) continue;
                            if (fab === 'P56' && !r.isP56) continue;
                            if (fab === 'P14' && r.isP56) continue;
                            if (weekSet && !weekSet.has(r.wk)) continue;

                            const wk = r.wk || '';
                            const tool = r.tool || '';
                            const toolShort = r.toolShort || tool;
                            if (!wk || !toolShort) continue;

                            weeks.add(wk);
                            let m = map.get(wk);
                            if (!m) { m = new Map(); map.set(wk, m); }
                            m.set(toolShort, (m.get(toolShort) || 0) + 1);
                            toolsTotal.set(toolShort, (toolsTotal.get(toolShort) || 0) + 1);
                        }

                        const weekList = [...weeks].sort();
                        const toolList = [...toolsTotal.entries()]
                            .sort((a, b) => b[1] - a[1] || (a[0] < b[0] ? -1 : 1))
                            .slice(0, 40)
                            .map(x => x[0]);

                        // debug: ensure labels exist even if bars show
                        // (Chart.js can hide tick labels if there isn't enough room)


                        const palette = [
                            'rgba(54, 162, 235, 0.85)',
                            'rgba(255, 99, 132, 0.85)',
                            'rgba(255, 159, 64, 0.85)',
                            'rgba(75, 192, 192, 0.85)',
                            'rgba(153, 102, 255, 0.85)',
                            'rgba(201, 203, 207, 0.85)',
                            'rgba(255, 205, 86, 0.85)'
                        ];

                        eqWeekChart.data.labels = toolList;
                        eqWeekChart.data.datasets = weekList.map((wk, idx) => ({
                            label: wk,
                            data: toolList.map(t => (map.get(wk)?.get(t) || 0)),
                            backgroundColor: palette[idx % palette.length],
                            borderWidth: 0
                        }));

                        // Force show X ticks (EQPID) + avoid auto skip hiding all labels
                        eqWeekChart.options.scales.x.ticks.autoSkip = false;
                        eqWeekChart.options.scales.x.ticks.maxRotation = 60;
                        eqWeekChart.options.scales.x.ticks.minRotation = 60;
                        eqWeekChart.update();
                    }

                    function getRangeValue() {
                        const r = document.querySelector('input.range:checked');
                        return r ? r.value : '90';
                    }

                    function getRangeStartDate() {
                        const rv = getRangeValue();
                        if (rv === 'all') return null;
                        const days = parseInt(rv, 10);
                        const n = isNaN(days) ? trend.labels.length : days;
                        const start = Math.max(0, trend.labels.length - n);
                        const s = trend.labels[start];
                        if (!s) return null;
                        return new Date(s + 'T00:00:00');
                    }

                    function getFabValue() {
                        const r = document.querySelector('input.fab:checked');
                        return r ? r.value : 'ALL';
                    }

                    function getSeriesByFab() {
                        const fab = getFabValue();
                        const all = trend.seriesAll || trend.series;
                        if (fab === 'P14') return trend.seriesP14 || all;
                        if (fab === 'P56') return trend.seriesP56 || all;
                        return all;
                    }

                    function applyRange() {
                        const series = getSeriesByFab();
                        const rv = getRangeValue();

                        if (rv === 'all') {
                            chart.data.labels = trend.labels.slice();
                            chart.data.datasets.forEach(ds => { ds.data = (series[ds.label] || []).slice(); });
                        } else {
                            const days = parseInt(rv, 10);
                            const n = isNaN(days) ? trend.labels.length : days;
                            const start = Math.max(0, trend.labels.length - n);
                            chart.data.labels = trend.labels.slice(start);
                            chart.data.datasets.forEach(ds => {
                                const arr = series[ds.label] || [];
                                ds.data = arr.slice(start);
                            });
                        }
                    }

                    function getRangeMonthsSet() {
                        const rv = getRangeValue();
                        if (rv === 'all') return null;

                        const days = parseInt(rv, 10);
                        const n = isNaN(days) ? trend.labels.length : days;
                        const start = Math.max(0, trend.labels.length - n);
                        const labels = trend.labels.slice(start);
                        const set = new Set(labels.map(d => (d || '').replaceAll('-', '').slice(0, 6))); // yyyyMM
                        return set;
                    }

                    function syncTable(selected, monthSet) {
                        const fab = getFabValue();

                        // row filter (parent + child)
                        document.querySelectorAll('#countsTable .sec-row').forEach(tr => {
                            const sec = tr.getAttribute('data-section');
                            const isChild = tr.classList.contains('child-row');

                            if (!selected.has(sec)) {
                                tr.style.display = 'none';
                                return;
                            }

                            if (isChild) {
                                // FAB filter for child rows
                                const isP56 = tr.getAttribute('data-is-p56') === '1';
                                if (fab === 'P56' && !isP56) { tr.style.display = 'none'; return; }
                                if (fab === 'P14' && isP56) { tr.style.display = 'none'; return; }
                                // ALL: 不過濾

                                // child row: only show when parent expanded
                                const parent = tr.getAttribute('data-parent-section');
                                const parentRow = document.querySelector(`#countsTable tr.parent-row[data-section="${parent}"]`);
                                const expanded = parentRow && parentRow.getAttribute('data-expanded') === '1';
                                tr.style.display = expanded ? '' : 'none';
                            } else {
                                // parent row: 依 FAB 切換顯示不同數值（由後端在 td 上預先放 data-all/data-p14/data-p56）
                                const cells = tr.querySelectorAll('td.month-col');
                                cells.forEach(td => {
                                    const all = td.getAttribute('data-all');
                                    const p14 = td.getAttribute('data-p14');
                                    const p56 = td.getAttribute('data-p56');
                                    if (fab === 'P14' && p14 != null) td.textContent = p14;
                                    else if (fab === 'P56' && p56 != null) td.textContent = p56;
                                    else if (all != null) td.textContent = all;
                                });
                                tr.style.display = '';
                            }
                        });

                        // column filter by range (month table only)
                        document.querySelectorAll('#countsTable .month-col').forEach(td => {
                            const m = td.getAttribute('data-month');
                            td.style.display = (!monthSet || monthSet.has(m)) ? '' : 'none';
                        });
                    }

                    let activeSubEqpid = null; // e.g. NISACVD-04

                    function setChartType(t) {
                        chartType = t;

                        const trendSection = document.getElementById('trendChart')?.closest('.section');
                        const pieSection = document.getElementById('trendPieSection');
                        if (trendSection && pieSection) {
                            trendSection.style.display = (chartType === 'pie') ? 'none' : '';
                            pieSection.style.display = (chartType === 'pie') ? '' : 'none';
                        }

                        if (chartType !== 'pie') {
                            chart.update();
                        }

                        // pie 需要四個圓餅圖（每個機群一張）
                        if (chartType === 'pie') {
                            renderToolPieCharts();
                        }
                    }

                    let __pieCharts = [];

                    function destroyPieCharts() {
                        if (!__pieCharts) __pieCharts = [];
                        __pieCharts.forEach(c => { try { c.destroy(); } catch (e) { } });
                        __pieCharts = [];
                    }

                    function renderToolPieCharts() {
                        destroyPieCharts();

                        const selected = new Set([...document.querySelectorAll('input.eqpid:checked')].map(x => x.value));
                        const fab = getFabValue();
                        const startDate = getRangeStartDate();

                        const order = ['NISACVD', 'SACVD'];
                        const palette = ['#60a5fa', '#f87171', '#fbbf24', '#34d399', '#a78bfa', '#fb7185', '#22c55e', '#38bdf8', '#f97316', '#e879f9', '#94a3b8', '#f43f5e', '#10b981'];

                        for (const sec of order) {
                            const canvas = document.getElementById('pie_' + sec);
                            if (!canvas) continue;

                            // tool -> count
                            const m = new Map();
                            let total = 0;

                            for (const r of perfRows) {
                                if (!r) continue;
                                if (!selected.has(r.sec)) continue;
                                if (r.sec !== sec) continue;

                                if (fab === 'P56' && !r.isP56) continue;
                                if (fab === 'P14' && r.isP56) continue;

                                if (startDate) {
                                    const d = new Date((r.d || '') + 'T00:00:00');
                                    if (!(d >= startDate)) continue;
                                }

                                const tool = r.tool || '';
                                if (!tool) continue;
                                total++;
                                m.set(tool, (m.get(tool) || 0) + 1);
                            }

                            const items = [...m.entries()]
                                .map(([tool, count]) => ({ tool, count }))
                                .sort((a, b) => b.count - a.count || (a.tool < b.tool ? -1 : 1));

                            // Top 12 + Others
                            const top = items.slice(0, 12);
                            const rest = items.slice(12);
                            const otherCount = rest.reduce((s, x) => s + x.count, 0);
                            const labels = top.map(x => x.tool).concat(otherCount > 0 ? ['Others'] : []);
                            const data = top.map(x => x.count).concat(otherCount > 0 ? [otherCount] : []);
                            const bg = labels.map((_, i) => palette[i % palette.length]);

                            // title above pie
                            const titleEl = document.getElementById('pie_title_' + sec);
                            if (titleEl) titleEl.textContent = sec + ' (n=' + total + ')';

                            const c = new Chart(canvas.getContext('2d'), {
                                type: 'pie',
                                data: { labels, datasets: [{ data, backgroundColor: bg, borderWidth: 0 }] },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        legend: {
                                            position: 'right',
                                            labels: {
                                                color: '#ffffff',
                                                boxWidth: 10,
                                                font: { size: 11, weight: '700' },
                                                padding: 10,
                                                generateLabels: (chart0) => {
                                                    const data0 = chart0.data;
                                                    const ds0 = data0.datasets && data0.datasets[0];
                                                    const arr = (ds0 && ds0.data) ? ds0.data : [];
                                                    let sum = 0;
                                                    for (let i = 0; i < arr.length; i++) sum += (arr[i] || 0);

                                                    const labels0 = data0.labels || [];
                                                    return labels0.map((lbl, i) => {
                                                        const v = arr[i] || 0;
                                                        const p = sum ? ((v / sum) * 100).toFixed(1) : '0.0';
                                                        const bg = (ds0 && ds0.backgroundColor) ? ds0.backgroundColor[i] : '#999';
                                                        return {
                                                            text: String(lbl) + ' ' + p + '%',
                                                            fillStyle: bg,
                                                            strokeStyle: bg,
                                                            lineWidth: 0,
                                                            hidden: false,
                                                            index: i,
                                                            fontColor: '#ffffff'
                                                        };
                                                    });
                                                }
                                            }
                                        },
                                        tooltip: {
                                            callbacks: {
                                                label: (ctx) => {
                                                    const v = ctx.raw || 0;
                                                    const p = total ? ((v / total) * 100).toFixed(1) : '0.0';
                                                    return ' ' + ctx.label + ': ' + v + ' (' + p + '%)';
                                                }
                                            }
                                        }
                                    }
                                }
                            });
                            __pieCharts.push(c);
                        }
                    }

                    function applyCardFilter(selected) {
                        const fab = getFabValue();
                        const qLot = (document.getElementById('qLot')?.value || '').trim().toLowerCase();
                        const qEqp = (document.getElementById('qEqp')?.value || '').trim().toLowerCase();
                        const startDate = getRangeStartDate();

                        // 先依 top checkbox 決定 section 顯示
                        document.querySelectorAll('.sections > [data-section]').forEach(sectionEl => {
                            const sec = sectionEl.getAttribute('data-section');
                            sectionEl.style.display = selected.has(sec) ? '' : 'none';
                        });

                        // 再依 activeSubEqpid + FAB + Search + Range 過濾卡片
                        document.querySelectorAll('.item[data-sub-eqpid]').forEach(item => {
                            const sec = item.getAttribute('data-parent-section');
                            if (!selected.has(sec)) { item.style.display = 'none'; return; }

                            const isP56 = item.getAttribute('data-is-p56') === '1';
                            if (fab === 'P56' && !isP56) { item.style.display = 'none'; return; }
                            if (fab === 'P14' && isP56) { item.style.display = 'none'; return; }

                            if (activeSubEqpid && item.getAttribute('data-sub-eqpid') !== activeSubEqpid) { item.style.display = 'none'; return; }

                            // Range filter by DataDate (item date chip text = yyyy/MM/dd)
                            if (startDate) {
                                const dateText = (item.querySelector('.item-collapsed .date')?.textContent || '').trim();
                                if (dateText) {
                                    // accept yyyy-MM-dd / yyyy/MM/dd
                                    const norm = dateText.replaceAll('/', '-');
                                    const d = new Date(norm + 'T00:00:00');
                                    if (!(d >= startDate)) { item.style.display = 'none'; return; }
                                }
                            }

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
                    }

                    function setActiveSubEqpid(sub) {
                        activeSubEqpid = sub;
                        document.querySelectorAll('#countsTable tr.child-row').forEach(tr => {
                            tr.style.outline = (tr.getAttribute('data-sub-eqpid') === sub) ? '2px solid rgba(99,179,237,0.55)' : '';
                        });
                    }

                    function wireExpandableTable() {
                        const table = document.getElementById('countsTable');
                        if (!table) return;

                        // expand/collapse by clicking parent
                        table.querySelectorAll('tr.parent-row .parent-cell').forEach(cell => {
                            cell.addEventListener('click', () => {
                                const row = cell.closest('tr.parent-row');
                                const sec = row.getAttribute('data-section');
                                const expanded = row.getAttribute('data-expanded') === '1';
                                row.setAttribute('data-expanded', expanded ? '0' : '1');

                                // 收合時如果正在看這個 sec 的子分類，就清掉 filter
                                if (expanded && activeSubEqpid && activeSubEqpid.startsWith(sec + '-')) {
                                    setActiveSubEqpid(null);
                                }

                                const selected = new Set([...document.querySelectorAll('input.eqpid:checked')].map(x => x.value));
                                const monthSet = getRangeMonthsSet();
                                syncTable(selected, monthSet);
                                applyCardFilter(selected);
                            });
                        });

                        // click child row to filter right-side cards
                        table.querySelectorAll('tr.child-row').forEach(tr => {
                            tr.addEventListener('click', () => {
                                const sub = tr.getAttribute('data-sub-eqpid');
                                const selected = new Set([...document.querySelectorAll('input.eqpid:checked')].map(x => x.value));

                                // toggle
                                if (activeSubEqpid === sub) {
                                    setActiveSubEqpid(null);
                                } else {
                                    setActiveSubEqpid(sub);
                                }
                                applyCardFilter(selected);
                            });
                        });
                    }

                    // week table 左欄點擊：
                    // 1) 點大類：展開/收合 child row + 勾選分類
                    // 2) 點子列：只顯示該機台相關資料
                    document.addEventListener('click', (ev) => {
                        // child click
                        const childRow = ev.target && ev.target.closest ? ev.target.closest('#weeklySection tr.week-child[data-sub-eqpid]') : null;
                        if (childRow) {
                            const sec = childRow.getAttribute('data-parent-section');
                            const sub = childRow.getAttribute('data-sub-eqpid');
                            if (sec) {
                                document.querySelectorAll('input.eqpid').forEach(cb => { cb.checked = (cb.value === sec); });
                            }
                            activeSubEqpid = sub || null;
                            syncVisibility();
                            return;
                        }

                        // parent click
                        const td = ev.target && ev.target.closest ? ev.target.closest('#weeklySection td.week-sec[data-section]') : null;
                        if (!td) return;
                        const sec = td.getAttribute('data-section');
                        if (!sec) return;

                        // toggle expand
                        const parentRow = td.closest('tr.week-parent');
                        if (parentRow) {
                            const expanded = parentRow.getAttribute('data-expanded') === '1';
                            parentRow.setAttribute('data-expanded', expanded ? '0' : '1');
                            document.querySelectorAll(`#weeklySection tr.week-child[data-parent-section="${sec}"]`).forEach(tr => {
                                tr.style.display = expanded ? 'none' : '';
                            });
                        }

                        // filter cards by section
                        document.querySelectorAll('input.eqpid').forEach(cb => { cb.checked = (cb.value === sec); });
                        activeSubEqpid = null;
                        syncVisibility();
                    });

                    function syncCountsTableVisibility() {
                        const grain = document.querySelector('input.countgrain:checked')?.value || 'month';
                        const monthEl = document.getElementById('monthlySection');
                        const weekEl = document.getElementById('weeklySection');
                        if (monthEl) monthEl.style.display = (grain === 'month') ? '' : 'none';
                        if (weekEl) weekEl.style.display = (grain === 'week') ? '' : 'none';
                    }

                    function getRangeWeeksSet() {
                        const rv = getRangeValue();
                        if (rv === 'all') return null;

                        const days = parseInt(rv, 10);
                        const n = isNaN(days) ? trend.labels.length : days;
                        const start = Math.max(0, trend.labels.length - n);
                        const labels = trend.labels.slice(start);

                        // labels = yyyy-MM-dd -> 轉成 weekStart(yyyyMMdd, Monday)
                        const set = new Set();
                        labels.forEach(s => {
                            if (!s) return;
                            const d = new Date(s + 'T00:00:00');
                            const dow = d.getDay(); // Sun=0
                            const offset = (dow === 0) ? -6 : (1 - dow);
                            d.setDate(d.getDate() + offset);
                            const yyyy = d.getFullYear();
                            const mm = String(d.getMonth() + 1).padStart(2, '0');
                            const dd = String(d.getDate()).padStart(2, '0');
                            set.add(`${yyyy}${mm}${dd}`);
                        });
                        return set;
                    }

                    function syncCountsTableColumns() {
                        const grain = document.querySelector('input.countgrain:checked')?.value || 'month';
                        const fab = getFabValue();

                        if (grain === 'month') {
                            const monthSet = getRangeMonthsSet();
                            document.querySelectorAll('#monthlySection .month-col').forEach(td => {
                                const m = td.getAttribute('data-month');
                                td.style.display = (!monthSet || monthSet.has(m)) ? '' : 'none';

                                // 只針對月表「子列(機台)」標紅 >=3（跟著 FAB 切換後的數字）
                                const isChild = td.closest('tr')?.classList.contains('child-row');
                                if (isChild) {
                                    const v = parseInt((td.textContent || '').trim(), 10);
                                    if (!isNaN(v) && v >= 3) td.classList.add('hot');
                                    else td.classList.remove('hot');
                                } else {
                                    td.classList.remove('hot');
                                }
                            });
                        } else {
                            const weekSet = getRangeWeeksSet();

                            // Week 子列依 FAB 過濾：P56 只留 Bxx；P14 排除 Bxx；ALL 全留
                            document.querySelectorAll('#weeklySection tr.week-child[data-is-p56]').forEach(tr => {
                                const isP56Child = tr.getAttribute('data-is-p56') === '1';
                                const parent = tr.getAttribute('data-parent-section');
                                const parentRow = parent ? document.querySelector(`#weeklySection tr.week-parent[data-section="${parent}"]`) : null;
                                const expanded = parentRow && parentRow.getAttribute('data-expanded') === '1';

                                let passFab = true;
                                if (fab === 'P56') passFab = isP56Child;
                                else if (fab === 'P14') passFab = !isP56Child;

                                // 仍尊重展開/收合狀態
                                tr.style.display = (expanded && passFab) ? '' : 'none';
                            });

                            document.querySelectorAll('#weeklySection .week-col').forEach(td => {
                                const w = td.getAttribute('data-week');
                                td.style.display = (!weekSet || weekSet.has(w)) ? '' : 'none';

                                // 依 FAB 切換數字（td 上有 data-all/data-p14/data-p56）
                                const all = td.getAttribute('data-all');
                                const p14 = td.getAttribute('data-p14');
                                const p56 = td.getAttribute('data-p56');
                                if (fab === 'P14' && p14 != null) td.textContent = p14;
                                else if (fab === 'P56' && p56 != null) td.textContent = p56;
                                else if (all != null) td.textContent = all;

                                // 只針對週表「子列(機台)」標紅 >=3
                                const isChild = td.closest('tr')?.classList.contains('week-child');
                                if (isChild) {
                                    const v = parseInt((td.textContent || '').trim(), 10);
                                    if (!isNaN(v) && v >= 3) td.classList.add('hot');
                                    else td.classList.remove('hot');
                                } else {
                                    td.classList.remove('hot');
                                }
                            });
                        }
                    }

                    function calcPerfBySection() {
                        const selected = new Set([...document.querySelectorAll('input.eqpid:checked')].map(x => x.value));
                        const fab = getFabValue();
                        const startDate = getRangeStartDate();

                        // sec -> tool -> {count, latest}
                        const secMap = new Map();
                        const secTotal = new Map();

                        // ensure fixed sections exist
                        ['NISACVD', 'SACVD'].forEach(s => {
                            if (!secMap.has(s)) secMap.set(s, new Map());
                            if (!secTotal.has(s)) secTotal.set(s, 0);
                        });

                        for (const r of perfRows) {
                            if (!r) continue;
                            if (!selected.has(r.sec)) continue;
                            if (fab === 'P56' && !r.isP56) continue;
                            if (fab === 'P14' && r.isP56) continue;

                            if (startDate) {
                                const d = new Date((r.d || '') + 'T00:00:00');
                                if (!(d >= startDate)) continue;
                            }

                            const sec = r.sec || '';
                            const tool = r.tool || '';
                            if (!sec || !tool) continue;

                            // ensure sec bucket exists
                            let m = secMap.get(sec);
                            if (!m) { m = new Map(); secMap.set(sec, m); }

                            secTotal.set(sec, (secTotal.get(sec) || 0) + 1);

                            let v = m.get(tool);
                            if (!v) { v = { count: 0, latest: r.d || '' }; m.set(tool, v); }
                            v.count++;
                            if ((r.d || '') > (v.latest || '')) v.latest = r.d || '';
                        }

                        return { secMap, secTotal };
                    }

                    function renderPerformanceTable() {
                        const tbody = document.querySelector('#perfTable tbody');
                        if (!tbody) return;

                        const { secMap, secTotal } = calcPerfBySection();
                        const secOrder = ['NISACVD', 'SACVD'];

                        let html = '';
                        const maxShowPerSec = 30;

                        for (const sec of secOrder) {
                            const m = secMap.get(sec);
                            if (!m) continue;

                            const rows = [...m.entries()].map(([tool, v]) => ({ tool, count: v.count, latest: v.latest }))
                                .sort((a, b) => b.count - a.count || (a.tool < b.tool ? -1 : 1));

                            const total = secTotal.get(sec) || 0;
                            html += `<tr><td colspan="4" style="padding:8px; font-weight:900; border-bottom:1px solid rgba(255,255,255,0.12); background:rgba(255,255,255,0.04);">${sec} (n=${total})</td></tr>`;

                            rows.slice(0, maxShowPerSec).forEach(x => {
                                const share = total ? ((x.count / total) * 100).toFixed(1) + '%' : '0.0%';
                                const toolEsc = String(x.tool).replaceAll('"', '&quot;');
                                html += `<tr>
                                    <td><span class="perf-tool" data-tool="${toolEsc}">${x.tool}</span></td>
                                    <td class="num">${x.count}</td>
                                    <td class="num">${share}</td>
                                    <td class="num">${x.latest || ''}</td>
                                </tr>`;
                            });
                        }

                        // 如果某些 tool 不屬於四群（理論上不會，因為後端已 filter），也留一個 OTHER
                        const otherTotal = secTotal.get('OTHER') || 0;
                        if (otherTotal) {
                            const m = secMap.get('OTHER');
                            if (m) {
                                const rows = [...m.entries()].map(([tool, v]) => ({ tool, count: v.count, latest: v.latest }))
                                    .sort((a, b) => b.count - a.count || (a.tool < b.tool ? -1 : 1));
                                html += `<tr><td colspan="4" style="padding:8px; font-weight:900; border-bottom:1px solid rgba(255,255,255,0.12); background:rgba(255,255,255,0.04);">OTHER (n=${otherTotal})</td></tr>`;
                                rows.slice(0, maxShowPerSec).forEach(x => {
                                    const share = otherTotal ? ((x.count / otherTotal) * 100).toFixed(1) + '%' : '0.0%';
                                    const toolEsc = String(x.tool).replaceAll('"', '&quot;');
                                    html += `<tr>
                                        <td><span class="perf-tool" data-tool="${toolEsc}">${x.tool}</span></td>
                                        <td class="num">${x.count}</td>
                                        <td class="num">${share}</td>
                                        <td class="num">${x.latest || ''}</td>
                                    </tr>`;
                                });
                            }
                        }

                        tbody.innerHTML = html;

                        const hint = document.getElementById('perfHint');
                        if (hint) {
                            hint.textContent = html
                                ? `Grouped by section. Showing top ${maxShowPerSec} per section.`
                                : 'No data in selected range.';
                        }
                    }


                    // 點 performance table 的 EQPID：塞到 EQPID search，清掉子分類 filter
                    document.addEventListener('click', (ev) => {
                        const el = ev.target && ev.target.closest ? ev.target.closest('.perf-tool[data-tool]') : null;
                        if (!el) return;
                        const tool = el.getAttribute('data-tool') || '';
                        const input = document.getElementById('qEqp');
                        if (input) input.value = tool;
                        activeSubEqpid = null;
                        syncVisibility();
                    });

                    function syncVisibility() {
                        const selected = new Set([...document.querySelectorAll('input.eqpid:checked')].map(x => x.value));
                        chart.data.datasets.forEach(ds => { ds.hidden = !selected.has(ds.label); });

                        applyRange();
                        chart.update();

                        // 同步 performance table（依 Range + FAB + EQPID）
                        renderPerformanceTable();

                        // 同步 EQPID x week chart
                        renderEqWeekChart();

                        // 如果目前是 Pie，Pie 也要即時重算
                        const ct = document.querySelector('input.charttype:checked')?.value || 'bar';
                        if (ct === 'pie') {
                            renderToolPieCharts();
                        }

                        // 同步卡片區塊（含子分類 filter + FAB）
                        applyCardFilter(selected);

                        // 同步月份表格（含 FAB）
                        const monthSet = getRangeMonthsSet();
                        syncTable(selected, monthSet);

                        // 切換 Month/Week 表格顯示 + 依 Range 隱藏欄位
                        syncCountsTableVisibility();
                        syncCountsTableColumns();
                    }

                    function wireCardToggle() {
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

                    document.querySelectorAll('input.fab').forEach(rb => rb.addEventListener('change', syncVisibility));
                    document.querySelectorAll('input.eqpid').forEach(cb => cb.addEventListener('change', syncVisibility));
                    document.querySelectorAll('input.range').forEach(rb => rb.addEventListener('change', syncVisibility));

                    // Counts Month/Week 會有兩份（month表/ week表），用事件委派避免漏綁
                    document.addEventListener('change', (ev) => {
                        const t = ev.target;
                        if (t && t.classList && t.classList.contains('countgrain')) {
                            syncVisibility();
                        }
                    });

                    // Chart type (Bar/Pie)
                    document.querySelectorAll('input.charttype').forEach(rb => rb.addEventListener('change', () => {
                        const v = document.querySelector('input.charttype:checked')?.value || 'bar';
                        setChartType(v);
                    }));

                    // Search：打字即時觸發過濾
                    const qLotEl = document.getElementById('qLot');
                    const qEqpEl = document.getElementById('qEqp');
                    if (qLotEl) qLotEl.addEventListener('input', syncVisibility);
                    if (qEqpEl) qEqpEl.addEventListener('input', syncVisibility);

                    // 置頂公告點擊：把 tool 塞進 EQPID 搜尋（contains 模式），並清掉子分類 filter
                    document.addEventListener('click', (ev) => {
                        const a = ev.target && ev.target.closest ? ev.target.closest('.notice-chip[data-tool]') : null;
                        if (!a) return;
                        const tool = a.getAttribute('data-tool') || '';
                        const input = document.getElementById('qEqp');
                        if (input) input.value = tool;

                        // 清掉子分類（避免看不到資料）
                        activeSubEqpid = null;
                        syncVisibility();
                    });

                    // reset filters to initial defaults
                    document.getElementById('btnReset')?.addEventListener('click', () => {
                        // FAB default = ALL
                        document.querySelectorAll('input.fab').forEach(rb => { rb.checked = (rb.value === 'ALL'); });
                        // EQPID default = all checked
                        document.querySelectorAll('input.eqpid').forEach(cb => { cb.checked = true; });
                        // Range default = 30D
                        document.querySelectorAll('input.range').forEach(rb => { rb.checked = (rb.value === '30'); });

                        // Counts grain default = month
                        document.querySelectorAll('input.countgrain').forEach(rb => { rb.checked = (rb.value === 'month'); });

                        // chart type UI default
                        document.querySelectorAll('input.charttype').forEach(rb => { rb.checked = (rb.value === 'bar'); });
                        setChartType('bar');
                        destroyPieCharts();

                        // clear search
                        const qLotEl = document.getElementById('qLot');
                        const qEqpEl = document.getElementById('qEqp');
                        if (qLotEl) qLotEl.value = '';
                        if (qEqpEl) qEqpEl.value = '';

                        // clear sub filter + collapse any expanded rows
                        activeSubEqpid = null;
                        document.querySelectorAll('#countsTable tr.parent-row').forEach(tr => tr.setAttribute('data-expanded', '0'));
                        document.querySelectorAll('#countsTable tr.child-row').forEach(tr => tr.style.display = 'none');
                        document.querySelectorAll('#weeklySection tr.week-parent').forEach(tr => tr.setAttribute('data-expanded', '0'));
                        document.querySelectorAll('#weeklySection tr.week-child').forEach(tr => tr.style.display = 'none');

                        // collapse expanded cards
                        document.querySelectorAll('.item.expanded').forEach(el => el.classList.remove('expanded'));

                        syncVisibility();
                    });

                    // open performance popup
                    document.getElementById('btnPerf')?.addEventListener('click', () => {
                        // 確保最新計算結果
                        renderPerformanceTable();

                        const html = `<!doctype html>
<html><head><meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Performance</title>
<style>${document.querySelector('style')?.innerHTML || ''}</style>
</head><body style="background: var(--bg); color: var(--text); margin:0;">
<div class="container" style="max-width:1280px; margin:16px auto; padding:0 16px;">
  <div class="card">
    <div class="card-header">
      <h1 class="title">Performance</h1>
      <div class="subtitle">Range=${getRangeValue()}D, FAB=${getFabValue()}</div>
    </div>
    <div class="card-body">
      <div style="overflow:auto;">${document.getElementById('perfTable')?.outerHTML || ''}</div>
      <div class="muted" style="margin-top:10px; font-size:12px;">(This window is read-only)</div>
    </div>
  </div>
</div>
</body></html>`;

                        const w = window.open('', 'perfWin', 'width=1100,height=700,scrollbars=yes,resizable=yes');
                        if (!w) {
                            alert('Popup blocked. Please allow popups for this site.');
                            return;
                        }
                        w.document.open();
                        w.document.write(html);
                        w.document.close();

                    });

                    function applyLayoutMode(mode) {
                        const l1 = document.getElementById('layout1');
                        const l2 = document.getElementById('layout2');
                        const btn = document.getElementById('btnLayout');
                        if (!l1 || !l2 || !btn) return;

                        if (mode === 2) {
                            l1.style.display = 'none';
                            l2.style.display = '';
                            btn.textContent = '版面一';

                            // move counts table blocks + section blocks into layout2 containers
                            const countsMonth = document.getElementById('monthlySection');
                            const countsWeek = document.getElementById('weeklySection');
                            const cWrap = document.getElementById('layout2Counts');
                            if (cWrap) {
                                cWrap.innerHTML = '';
                                if (countsMonth) cWrap.appendChild(countsMonth);
                                if (countsWeek) cWrap.appendChild(countsWeek);
                            }

                            const secWrap = document.getElementById('layout2Sections');
                            if (secWrap) {
                                secWrap.innerHTML = '';
                                document.querySelectorAll('.section[data-section]').forEach(sec => { secWrap.appendChild(sec); });
                            }
                        } else {
                            l2.style.display = 'none';
                            l1.style.display = '';
                            btn.textContent = '版面二';

                            // restore: put counts + sections back into layout1 (top-level container)
                            const l1El = document.getElementById('layout1');
                            if (l1El) {
                                // ensure counts sections are before the 4 sections grid in layout1: we insert at top of layout1
                                const countsMonth = document.getElementById('monthlySection');
                                const countsWeek = document.getElementById('weeklySection');
                                if (countsMonth) l1El.insertBefore(countsMonth, l1El.firstChild);
                                if (countsWeek) l1El.insertBefore(countsWeek, l1El.firstChild);

                                // append sections back
                                document.querySelectorAll('#layout2Sections .section[data-section]').forEach(sec => { l1El.appendChild(sec); });
                            }
                        }

                        // after DOM move, re-sync visibility (month/week) and filters
                        syncVisibility();
                    }

                    let __layoutMode = 1;
                    document.getElementById('btnLayout')?.addEventListener('click', () => {
                        __layoutMode = (__layoutMode === 1) ? 2 : 1;
                        applyLayoutMode(__layoutMode);
                    });

                    wireExpandableTable();
                    wireCardToggle();
                    syncVisibility();
                </script>
            </div>
        </div>
    </div>
</body>
</html>
