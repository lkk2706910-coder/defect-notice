"""
user_hash.py - Defect Lesson Learn 帳號 hash 產生器

用途:在不打 HTTP API、不靠 PowerShell 的前提下,把帳號/密碼產生成
DefectLessonLearn 的 users.json 需要的格式(salt + SHA-256 + base64),
直接寫進 server 共享資料夾的 App_Data\\users.json。

兩種使用模式:
  1) 單筆建立:填帳號 / 密碼 / 權限 → 產生 JSON → 寫進 users.json
  2) Excel 批次:下載範本 → Excel 填多筆 → 匯入 → 批次寫入 users.json

Excel 功能需要 openpyxl:
    pip install openpyxl

跑法(Python 3.6+):
    python user_hash.py
或在 Windows 雙擊。

產生的格式跟 .cs 的 NewToken().Substring(0,16) + Sha256B64(salt+pwd) 完全一致,
所以這支工具寫的帳號,在網頁上一樣能登入。
"""

import base64
import hashlib
import json
import os
import secrets
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

try:
    from openpyxl import Workbook, load_workbook
    from openpyxl.styles import Font, PatternFill, Alignment
    OPENPYXL_AVAILABLE = True
except ImportError:
    OPENPYXL_AVAILABLE = False


# ============================================================
#  Crypto / entry helpers
# ============================================================

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


def merge_users_json(path: str, new_entries: list) -> tuple:
    """合併 new_entries 到 users.json,回傳 (added, replaced, total)。
    同名帳號會覆蓋。其他帳號不動。"""
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

    added = 0
    replaced = 0
    for entry in new_entries:
        name_lc = entry["name"].lower()
        found = False
        for i, u in enumerate(users):
            if isinstance(u, dict) and str(u.get("name", "")).lower() == name_lc:
                users[i] = entry
                replaced += 1
                found = True
                break
        if not found:
            users.append(entry)
            added += 1

    with open(path, "w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, indent=2)

    return added, replaced, len(users)


# ============================================================
#  GUI
# ============================================================

class App(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Defect Lesson Learn - 帳號 hash 產生器")
        self.geometry("680x680")
        self.minsize(620, 560)

        outer = ttk.Frame(self, padding=12)
        outer.pack(fill="both", expand=True)
        outer.columnconfigure(1, weight=1)

        # =========================================
        #  Section 1: Single-user create
        # =========================================
        ttk.Label(outer, text="── 單筆建立 ──", font=("", 10, "bold")).grid(
            row=0, column=0, columnspan=2, sticky="w", pady=(0, 6)
        )

        ttk.Label(outer, text="帳號").grid(row=1, column=0, sticky="w", pady=4)
        self.user_var = tk.StringVar()
        ttk.Entry(outer, textvariable=self.user_var, width=40).grid(
            row=1, column=1, sticky="ew", pady=4
        )

        ttk.Label(outer, text="密碼").grid(row=2, column=0, sticky="w", pady=4)
        self.pwd_var = tk.StringVar()
        self.pwd_entry = ttk.Entry(outer, textvariable=self.pwd_var, width=40, show="*")
        self.pwd_entry.grid(row=2, column=1, sticky="ew", pady=4)

        self.show_pwd = tk.IntVar()
        ttk.Checkbutton(
            outer, text="顯示密碼", variable=self.show_pwd, command=self._toggle_pwd
        ).grid(row=3, column=1, sticky="w")

        ttk.Label(outer, text="權限").grid(row=4, column=0, sticky="w", pady=4)
        role_row = ttk.Frame(outer)
        role_row.grid(row=4, column=1, sticky="w", pady=4)
        self.role_var = tk.StringVar(value="editor")
        ttk.Radiobutton(
            role_row, text="編輯 (可看可改)", variable=self.role_var, value="editor"
        ).pack(side="left")
        ttk.Radiobutton(
            role_row, text="閱讀 (只能看)", variable=self.role_var, value="viewer"
        ).pack(side="left", padx=(12, 0))

        single_btns = ttk.Frame(outer)
        single_btns.grid(row=5, column=0, columnspan=2, pady=(8, 0), sticky="ew")
        ttk.Button(single_btns, text="產生 JSON", command=self._generate).pack(
            side="left", padx=(0, 6)
        )
        ttk.Button(single_btns, text="複製這一筆", command=self._copy_one).pack(
            side="left", padx=6
        )
        ttk.Button(
            single_btns, text="寫進 users.json", command=self._write_single
        ).pack(side="left", padx=6)

        ttk.Separator(outer, orient="horizontal").grid(
            row=6, column=0, columnspan=2, sticky="ew", pady=14
        )

        # =========================================
        #  Section 2: Excel batch import
        # =========================================
        ttk.Label(outer, text="── 批次匯入 (Excel) ──", font=("", 10, "bold")).grid(
            row=7, column=0, columnspan=2, sticky="w", pady=(0, 6)
        )

        excel_btns = ttk.Frame(outer)
        excel_btns.grid(row=8, column=0, columnspan=2, pady=(0, 6), sticky="ew")
        self.btn_template = ttk.Button(
            excel_btns, text="下載 Excel 範本", command=self._download_template
        )
        self.btn_template.pack(side="left", padx=(0, 6))
        self.btn_import = ttk.Button(
            excel_btns, text="匯入 Excel (產生預覽)", command=self._import_excel
        )
        self.btn_import.pack(side="left", padx=6)
        self.btn_batch_write = ttk.Button(
            excel_btns, text="批次寫進 users.json", command=self._write_batch
        )
        self.btn_batch_write.pack(side="left", padx=6)

        if not OPENPYXL_AVAILABLE:
            ttk.Label(
                outer,
                text="(尚未安裝 openpyxl → 終端機跑:  pip install openpyxl)",
                foreground="#b91c1c",
                font=("", 9),
            ).grid(row=9, column=0, columnspan=2, sticky="w", pady=(0, 4))

        # =========================================
        #  Output
        # =========================================
        ttk.Label(outer, text="輸出").grid(
            row=10, column=0, columnspan=2, sticky="w", pady=(8, 2)
        )
        self.output = tk.Text(
            outer, height=12, wrap="word", font=("Consolas", 10), background="#f7f7f7"
        )
        self.output.grid(row=11, column=0, columnspan=2, sticky="nsew")
        outer.rowconfigure(11, weight=1)

        # =========================================
        #  Hint + status
        # =========================================
        hint = (
            "提示:\n"
            "  - 單筆模式:填欄位 → 產生 → 寫入。寫入時選 server 端的 App_Data\\users.json。\n"
            "  - 批次模式:先下載範本 → Excel 填好多筆 → 匯入(會顯示預覽)→ 批次寫入。\n"
            "  - 同名帳號會被覆蓋(等同改密碼),其他帳號不動。"
        )
        ttk.Label(
            outer, text=hint, foreground="#555", justify="left", font=("", 9)
        ).grid(row=12, column=0, columnspan=2, sticky="w", pady=(8, 0))

        self.status = ttk.Label(self, text="就緒", relief="sunken", anchor="w")
        self.status.pack(side="bottom", fill="x")

        # State
        self.last_entry: dict | None = None
        self.last_batch: list = []

    # =========================================
    #  Single-user handlers
    # =========================================

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
        self.last_batch = []  # single-user mode displaces any pending batch
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
        self.update()
        self.status.config(text="已複製 1 筆到剪貼簿")

    def _write_single(self) -> None:
        if not self.last_entry:
            messagebox.showwarning("沒有資料", "請先點「產生 JSON」")
            return
        path = self._ask_users_json_path()
        if not path:
            return
        try:
            added, replaced, total = merge_users_json(path, [self.last_entry])
            verb = "更新" if replaced else "新增"
            self.status.config(text=f"已{verb}帳號到 {path}")
            messagebox.showinfo(
                "完成",
                f"已{verb}帳號「{self.last_entry['name']}」到:\n{path}\n\n目前共 {total} 個帳號。",
            )
        except Exception as e:
            messagebox.showerror("錯誤", f"寫檔失敗:\n{e}")

    # =========================================
    #  Excel batch handlers
    # =========================================

    def _download_template(self) -> None:
        if not OPENPYXL_AVAILABLE:
            self._openpyxl_missing()
            return
        path = filedialog.asksaveasfilename(
            title="儲存範本",
            defaultextension=".xlsx",
            filetypes=[("Excel", "*.xlsx")],
            initialfile="users_template.xlsx",
        )
        if not path:
            return
        try:
            wb = Workbook()
            ws = wb.active
            ws.title = "Users"

            headers = ["Username", "Password", "Role"]
            for col_idx, h in enumerate(headers, start=1):
                cell = ws.cell(row=1, column=col_idx, value=h)
                cell.font = Font(bold=True, color="FFFFFF")
                cell.fill = PatternFill("solid", fgColor="2563EB")
                cell.alignment = Alignment(horizontal="center")

            # Example rows
            examples = [
                ("alice",   "alicePass123", "editor"),
                ("bob",     "bobPass456",   "viewer"),
                ("charlie", "fab2026",      "editor"),
            ]
            for r_idx, row in enumerate(examples, start=2):
                for c_idx, v in enumerate(row, start=1):
                    ws.cell(row=r_idx, column=c_idx, value=v)

            ws.column_dimensions["A"].width = 22
            ws.column_dimensions["B"].width = 22
            ws.column_dimensions["C"].width = 12
            ws.column_dimensions["E"].width = 60

            ws["E1"] = "說明"
            ws["E1"].font = Font(bold=True)
            ws["E2"] = "每列一個帳號;Username + Password 必填。"
            ws["E3"] = "Role 留白 = editor。可填 editor 或 viewer。"
            ws["E4"] = "Username 空白的列會被跳過。"
            ws["E5"] = "同名帳號匯入時會覆蓋,等同改密碼。"
            ws["E6"] = "範例列填好後,記得刪掉或改成你自己的資料。"

            ws.freeze_panes = "A2"
            wb.save(path)
            self.status.config(text=f"範本已存到 {path}")
            messagebox.showinfo(
                "完成",
                f"範本已儲存:\n{path}\n\n打開 Excel,從第 2 列開始填,Username + Password 必填,"
                "Role 留白會自動視為 editor。"
            )
        except Exception as e:
            messagebox.showerror("錯誤", f"產生範本失敗:\n{e}")

    def _import_excel(self) -> None:
        if not OPENPYXL_AVAILABLE:
            self._openpyxl_missing()
            return
        src = filedialog.askopenfilename(
            title="選擇 Excel 檔",
            filetypes=[("Excel", "*.xlsx"), ("All files", "*.*")],
        )
        if not src:
            return
        try:
            wb = load_workbook(src, read_only=True, data_only=True)
            ws = wb.active

            # Map header names (case-insensitive) -> column index
            header_map = {}
            first_row = next(ws.iter_rows(min_row=1, max_row=1, values_only=True), None)
            if not first_row:
                messagebox.showerror("錯誤", "Excel 是空的")
                return
            for i, v in enumerate(first_row):
                if v is None:
                    continue
                key = str(v).strip().lower()
                if key in ("username", "password", "role"):
                    header_map[key] = i

            if "username" not in header_map or "password" not in header_map:
                messagebox.showerror(
                    "格式錯誤",
                    "Excel 第 1 列必須有 Username 和 Password 標題欄。\n"
                    "請先用「下載 Excel 範本」拿到正確格式。"
                )
                return

            entries: list = []
            skipped: list = []
            seen_names = set()
            for row_idx, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
                if row is None:
                    continue
                user = _cell(row, header_map["username"])
                pwd = _cell(row, header_map["password"])
                role = _cell(row, header_map.get("role", -1))
                # Skip rows with no username (treat blank rows as separators)
                if not user or not str(user).strip():
                    if pwd:
                        skipped.append(f"列 {row_idx} (沒帳號)")
                    continue
                user_s = str(user).strip()
                if not pwd:
                    skipped.append(f"列 {row_idx} \"{user_s}\" (沒密碼)")
                    continue
                pwd_s = str(pwd)
                if user_s.lower() in seen_names:
                    skipped.append(f"列 {row_idx} \"{user_s}\" (重複)")
                    continue
                seen_names.add(user_s.lower())
                role_s = (str(role).strip().lower() if role else "editor") or "editor"
                if role_s not in ("editor", "viewer"):
                    skipped.append(f"列 {row_idx} \"{user_s}\" (role 不認得: {role_s})")
                    role_s = "editor"
                entries.append(make_user_entry(user_s, pwd_s, role_s))

            if not entries:
                self.output.delete("1.0", "end")
                self.output.insert("1.0", "(沒有可匯入的有效資料列)")
                self.status.config(text="匯入 0 筆")
                messagebox.showwarning("沒有資料", "Excel 沒有可匯入的有效資料")
                return

            self.last_batch = entries
            self.last_entry = None  # batch mode displaces single-user pending
            # Render preview: pretty array
            preview = json.dumps(entries, ensure_ascii=False, indent=2)
            self.output.delete("1.0", "end")
            self.output.insert("1.0", preview)
            if skipped:
                self.output.insert("end", "\n\n// 跳過:\n// " + "\n// ".join(skipped))
            self.status.config(text=f"已解析 {len(entries)} 筆 (跳過 {len(skipped)})")
        except Exception as e:
            messagebox.showerror("匯入失敗", f"讀取 Excel 時出錯:\n{e}")

    def _write_batch(self) -> None:
        if not self.last_batch:
            messagebox.showwarning(
                "沒有資料", "請先「下載範本」→ Excel 填好 →「匯入 Excel」產生預覽"
            )
            return
        path = self._ask_users_json_path()
        if not path:
            return
        try:
            added, replaced, total = merge_users_json(path, self.last_batch)
            self.status.config(
                text=f"批次完成:新增 {added} 筆,更新 {replaced} 筆,共 {total} 個帳號"
            )
            messagebox.showinfo(
                "完成",
                f"已寫入:\n{path}\n\n"
                f"  新增 {added} 筆\n"
                f"  更新 {replaced} 筆(同名覆蓋)\n"
                f"  目前共 {total} 個帳號。"
            )
        except Exception as e:
            messagebox.showerror("錯誤", f"寫檔失敗:\n{e}")

    # =========================================
    #  helpers
    # =========================================

    def _ask_users_json_path(self) -> str:
        return filedialog.asksaveasfilename(
            title="選擇 users.json (新檔或既有,會自動合併)",
            defaultextension=".json",
            filetypes=[("JSON", "*.json"), ("All files", "*.*")],
            initialfile="users.json",
        )

    def _openpyxl_missing(self) -> None:
        messagebox.showerror(
            "缺少 openpyxl",
            "Excel 功能需要 openpyxl 套件。\n\n"
            "在終端機跑:\n    pip install openpyxl\n\n"
            "(如果公司網路擋外網,請跟 IT 要 internal mirror,"
            "或先在能上網的電腦裝起來再執行這支工具。)"
        )


def _cell(row, idx: int):
    """安全取 row[idx],idx 超出範圍時回 None。"""
    if idx is None or idx < 0:
        return None
    if idx >= len(row):
        return None
    return row[idx]


if __name__ == "__main__":
    App().mainloop()
