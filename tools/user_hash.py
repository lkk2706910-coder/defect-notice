"""
user_hash.py — Defect Lesson Learn 帳號 hash 產生器

用途:在不打 HTTP API、不靠 PowerShell 的前提下,把帳號/密碼產生成
DefectLessonLearn 的 users.json 需要的格式(salt + SHA-256 + base64),
直接寫進 server 共享資料夾的 App_Data\\users.json。

跑法(Python 3.6+ 即可,tkinter 是內建的):
    python user_hash.py

或在 Windows 直接雙擊。

產生的格式跟 .cs 中的 NewToken().Substring(0,16) + Sha256B64(salt+pwd) 一致,
所以這支工具寫進去的帳號,在頁面上一樣能登入。
"""

import base64
import hashlib
import json
import os
import secrets
import tkinter as tk
from tkinter import filedialog, messagebox, ttk


def make_salt() -> str:
    """16 字元的 URL-safe base64 字串。等同 .cs 的 NewToken().Substring(0,16)。"""
    raw = secrets.token_bytes(24)
    b64 = base64.b64encode(raw).decode("ascii").rstrip("=")
    b64 = b64.replace("/", "_").replace("+", "-")
    return b64[:16]


def hash_password(salt: str, password: str) -> str:
    """base64(SHA-256(UTF-8(salt + password)))。等同 .cs 的 Sha256B64(salt+pwd)。"""
    digest = hashlib.sha256((salt + password).encode("utf-8")).digest()
    return base64.b64encode(digest).decode("ascii")


def make_user_entry(username: str, password: str, role: str = "editor") -> dict:
    salt = make_salt()
    return {
        "name": username,
        "salt": salt,
        "hash": hash_password(salt, password),
        "role": role if role in ("editor", "viewer") else "editor",
    }


class App(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Defect Lesson Learn — 帳號 hash 產生器")
        self.geometry("620x500")
        self.minsize(560, 460)

        outer = ttk.Frame(self, padding=12)
        outer.pack(fill="both", expand=True)

        # --- Inputs ---
        ttk.Label(outer, text="帳號").grid(row=0, column=0, sticky="w", pady=4)
        self.user_var = tk.StringVar()
        ttk.Entry(outer, textvariable=self.user_var, width=40).grid(
            row=0, column=1, sticky="ew", pady=4
        )

        ttk.Label(outer, text="密碼").grid(row=1, column=0, sticky="w", pady=4)
        self.pwd_var = tk.StringVar()
        self.pwd_entry = ttk.Entry(outer, textvariable=self.pwd_var, width=40, show="*")
        self.pwd_entry.grid(row=1, column=1, sticky="ew", pady=4)

        self.show_pwd = tk.IntVar()
        ttk.Checkbutton(
            outer, text="顯示密碼", variable=self.show_pwd, command=self._toggle_pwd
        ).grid(row=2, column=1, sticky="w")

        ttk.Label(outer, text="權限").grid(row=3, column=0, sticky="w", pady=4)
        role_row = ttk.Frame(outer)
        role_row.grid(row=3, column=1, sticky="w", pady=4)
        self.role_var = tk.StringVar(value="editor")
        ttk.Radiobutton(
            role_row, text="編輯 (可看可改)", variable=self.role_var, value="editor"
        ).pack(side="left")
        ttk.Radiobutton(
            role_row, text="閱讀 (只能看)", variable=self.role_var, value="viewer"
        ).pack(side="left", padx=(12, 0))

        # --- Action buttons ---
        btn_row = ttk.Frame(outer)
        btn_row.grid(row=4, column=0, columnspan=2, pady=(10, 6), sticky="ew")
        ttk.Button(btn_row, text="產生 JSON", command=self._generate).pack(
            side="left", padx=(0, 6)
        )
        ttk.Button(btn_row, text="複製這一筆", command=self._copy_one).pack(
            side="left", padx=6
        )
        ttk.Button(
            btn_row, text="寫進 users.json (新檔或合併既有)", command=self._write_file
        ).pack(side="left", padx=6)

        # --- Output ---
        ttk.Label(
            outer,
            text="輸出 — 可直接複製貼到 users.json 的 users 陣列裡:",
        ).grid(row=5, column=0, columnspan=2, sticky="w", pady=(8, 2))

        self.output = tk.Text(
            outer, height=10, wrap="word", font=("Consolas", 10), background="#f7f7f7"
        )
        self.output.grid(row=6, column=0, columnspan=2, sticky="nsew")
        outer.rowconfigure(6, weight=1)
        outer.columnconfigure(1, weight=1)

        # --- Hint / footer ---
        hint = (
            "提示: 寫進 users.json 時,若資料夾是 server 的 \\\\umcesidb02\\TF\\...\\App_Data\\,\n"
            "      直接就把帳號加到 server 上,不用再走 API。\n"
            "      同名帳號會自動覆蓋(等於改密碼),其他帳號不受影響。"
        )
        ttk.Label(
            outer, text=hint, foreground="#555", justify="left", font=("", 9)
        ).grid(row=7, column=0, columnspan=2, sticky="w", pady=(8, 0))

        self.status = ttk.Label(self, text="就緒", relief="sunken", anchor="w")
        self.status.pack(side="bottom", fill="x")

        self.last_entry: dict | None = None

    # ------- handlers -------

    def _toggle_pwd(self) -> None:
        self.pwd_entry.config(show="" if self.show_pwd.get() else "*")

    def _generate(self) -> None:
        name = self.user_var.get().strip()
        pwd = self.pwd_var.get()
        if not name or not pwd:
            messagebox.showwarning("缺欄位", "請輸入帳號和密碼")
            return
        entry = make_user_entry(name, pwd, self.role_var.get())
        self.last_entry = entry
        pretty = json.dumps(entry, ensure_ascii=False, indent=2)
        self.output.delete("1.0", "end")
        self.output.insert("1.0", pretty)
        self.status.config(text=f"已產生:{name}  salt={entry['salt']}")

    def _copy_one(self) -> None:
        if not self.last_entry:
            messagebox.showwarning("沒有資料", "請先點「產生 JSON」")
            return
        text = json.dumps(self.last_entry, ensure_ascii=False)
        self.clipboard_clear()
        self.clipboard_append(text)
        # On Windows the clipboard needs the mainloop to flush; this nudges it.
        self.update()
        self.status.config(text="已複製 1 筆到剪貼簿")

    def _write_file(self) -> None:
        if not self.last_entry:
            messagebox.showwarning("沒有資料", "請先點「產生 JSON」")
            return
        path = filedialog.asksaveasfilename(
            title="選擇 users.json (新檔或既有,會自動合併)",
            defaultextension=".json",
            filetypes=[("JSON", "*.json"), ("All files", "*.*")],
            initialfile="users.json",
        )
        if not path:
            return
        try:
            doc = {}
            if os.path.exists(path):
                with open(path, "r", encoding="utf-8") as f:
                    raw = f.read().strip()
                    if raw:
                        doc = json.loads(raw)
                        if not isinstance(doc, dict):
                            doc = {}
            users = doc.setdefault("users", [])
            if not isinstance(users, list):
                raise ValueError("既有 users.json 的 'users' 欄位不是陣列")

            replaced = False
            for i, u in enumerate(users):
                if not isinstance(u, dict):
                    continue
                if str(u.get("name", "")).lower() == self.last_entry["name"].lower():
                    users[i] = self.last_entry
                    replaced = True
                    break
            if not replaced:
                users.append(self.last_entry)

            with open(path, "w", encoding="utf-8") as f:
                json.dump(doc, f, ensure_ascii=False, indent=2)

            verb = "更新" if replaced else "新增"
            self.status.config(text=f"已 {verb} 帳號到 {path}")
            messagebox.showinfo(
                "完成",
                f"已 {verb} 帳號「{self.last_entry['name']}」到:\n{path}\n\n"
                f"目前共 {len(users)} 個帳號。",
            )
        except Exception as e:
            messagebox.showerror("錯誤", f"寫檔失敗:\n{e}")


if __name__ == "__main__":
    App().mainloop()
