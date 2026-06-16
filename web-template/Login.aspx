<%@ Page Language="C#" AutoEventWireup="true" Inherits="Login" CodeFile="Login.aspx.cs" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>登入</title>
    <style>
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans TC", Arial, sans-serif;
            background: radial-gradient(1200px 600px at 20% 0%, #152a52 0%, #0b1220 60%);
            color: #e7eefc;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card {
            width: 360px;
            background: #0f1b33;
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 14px;
            padding: 28px 26px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
        }
        .card h1 { margin: 0 0 18px; font-size: 18px; }
        .card label { display: block; font-size: 12px; color: #a9b7d6; margin: 10px 0 4px; }
        .card input {
            width: 100%;
            background: rgba(5,10,20,0.30);
            border: 1px solid rgba(255,255,255,0.12);
            color: #e7eefc;
            padding: 9px 11px;
            border-radius: 8px;
            font-size: 13px;
            outline: none;
        }
        .card input:focus { border-color: #63b3ed; }
        .err {
            display: none;
            margin-top: 14px;
            padding: 8px 11px;
            font-size: 12px;
            color: #fbbf24;
            background: rgba(251,191,36,0.10);
            border: 1px solid rgba(251,191,36,0.40);
            border-radius: 6px;
        }
        .err.show { display: block; }
        .actions { margin-top: 18px; display: flex; justify-content: flex-end; }
        button[type="submit"] {
            padding: 9px 22px;
            background: #2563eb;
            color: #fff;
            border: 1px solid #2563eb;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
        }
        button[type="submit"]:hover { background: #1d4ed8; }
    </style>
</head>
<body>
    <form class="card" method="post" action="Login.aspx">
        <h1>登入</h1>
        <label for="u">使用者</label>
        <input type="text" id="u" name="username" autocomplete="username" autofocus required />
        <label for="p">密碼</label>
        <input type="password" id="p" name="password" autocomplete="current-password" required />
        <div class="err <%= string.IsNullOrEmpty(ErrorCode) ? "" : "show" %>"><%
            switch (ErrorCode) {
                case "empty":            Response.Write("請輸入帳號與密碼"); break;
                case "disabled":         Response.Write("此帳號已停用"); break;
                case "bad_credentials":  Response.Write("帳號或密碼錯誤"); break;
            }
        %></div>
        <div class="actions">
            <button type="submit">登入</button>
        </div>
    </form>
</body>
</html>
