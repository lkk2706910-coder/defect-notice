<%@ Page Language="C#" AutoEventWireup="true" %>

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
            --chip: rgba(99, 179, 237, 0.18);
        }

        * { box-sizing: border-box; }

        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, "Noto Sans", "Helvetica Neue", sans-serif;
            background: radial-gradient(1200px 600px at 20% 0%, #152a52 0%, var(--bg) 60%);
            color: var(--text);
            overflow: hidden;
        }

        .app {
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .tab-bar {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 12px 18px 0 18px;
            background: rgba(255,255,255,0.03);
            border-bottom: 1px solid var(--border);
            flex-shrink: 0;
        }

        .tab-title {
            font-size: 16px;
            font-weight: 800;
            letter-spacing: .02em;
            margin-right: 18px;
        }

        .tab-btn {
            font-family: inherit;
            font-size: 13px;
            font-weight: 700;
            padding: 10px 16px;
            border: 1px solid var(--border);
            border-bottom: none;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
            background: rgba(255,255,255,0.03);
            color: var(--muted);
            cursor: pointer;
            transition: background .15s, color .15s;
        }

        .tab-btn:hover {
            background: rgba(99, 179, 237, 0.10);
            color: var(--text);
        }

        .tab-btn.active {
            background: var(--bg);
            color: var(--text);
            border-color: var(--border);
            border-bottom-color: var(--bg);
            margin-bottom: -1px;
            position: relative;
            z-index: 2;
        }

        .tab-frames {
            flex: 1;
            position: relative;
            min-height: 0;
        }

        .tab-frame {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            border: 0;
            display: none;
        }

        .tab-frame.active {
            display: block;
        }
    </style>
</head>
<body>
    <div class="app">
        <div class="tab-bar">
            <span class="tab-title">Defect Notice</span>
            <button type="button" class="tab-btn active" data-tab="dash">主看版</button>
            <button type="button" class="tab-btn" data-tab="notice24">24hr Notice</button>
            <button type="button" class="tab-btn" data-tab="pivot">Pivot 分析</button>
        </div>
        <div class="tab-frames">
            <iframe id="frameDash"      class="tab-frame active" data-tab="dash"     src="Defectnotice.aspx"></iframe>
            <iframe id="frameNotice24"  class="tab-frame"        data-tab="notice24" data-src="Defectnotice2.aspx"></iframe>
            <iframe id="framePivot"     class="tab-frame"        data-tab="pivot"    data-src="Defectnotice4.aspx"></iframe>
        </div>
    </div>

    <script>
        // 按需載入：第一次切到 tab 時才設定 iframe 的 src
        (function () {
            const buttons = document.querySelectorAll('.tab-btn[data-tab]');
            const frames = document.querySelectorAll('.tab-frame[data-tab]');

            function activate(tab) {
                buttons.forEach(b => { b.classList.toggle('active', b.getAttribute('data-tab') === tab); });
                frames.forEach(f => {
                    const isActive = f.getAttribute('data-tab') === tab;
                    f.classList.toggle('active', isActive);
                    if (isActive && !f.src && f.dataset.src) {
                        f.src = f.dataset.src;
                    }
                });
            }

            buttons.forEach(b => {
                b.addEventListener('click', () => activate(b.getAttribute('data-tab')));
            });
        })();
    </script>
</body>
</html>
