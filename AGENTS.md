# AGENTS.md

Guidance for AI coding agents working in this repo. Companion to `CLAUDE.md`
(which documents the current branch in more detail). Read both.

## What this repo is

A collection of small **ASP.NET WebForms** (.NET Framework 4.x) single-page
tools for a semiconductor fab, each backed by SQL Server (`GPTPoCDB`). There is
no solution file, no build script, and no test suite — every page is a
self-contained `*.aspx` + `*.aspx.cs` pair that IIS compiles on the fly
(`CodeFile=`, not `CodeBehind=`). You "run" a page by deploying it to IIS with
a valid config; there is nothing to `dotnet build` here.

## Repository shape — branches are the unit, not folders

Different branches hold different (and sometimes overlapping) apps. There is no
`main`; the default working branch is `claude/read-all-branches-c4rles`. Know
which branch you are on before editing — the file set changes completely.

| Branch | Main app(s) |
|--------|-------------|
| `claude/read-all-branches-c4rles` | `Defectnotice{,2,4}.aspx` — Defect Notice DB browser (v1 table / v2 cards / v4 +cols) |
| `line_yield` | `LineYield.aspx` — Line Yield tracker (AI assistant, GPTPoCDB lookups, local login) |
| `claude/defect-case-lesson-learn`(`-ai-function`) | `DefectLessonLearn.aspx` + `ai-chat-widget/`, `web-template/` |
| `claude/ai-db-template` | `LineYield.aspx` + reusable `ai-chat-widget/`, `web-template{,-lite}/`, `login-edit-template/` |
| `claude/new-fab-sample`, `claude/original-version`, `claude/merge-all{,-v2}` | Defectnotice variants / merges |

The same file (e.g. `web.config`, `ai-chat-widget/AiChat.aspx.cs`) is often a
byte-identical copy across branches — a fix usually has to be applied to each
branch that carries it, not just once.

## Configuration & secrets (never commit real values)

- **DB credentials** live in `connections.config` (gitignored). `web.config`
  pulls them via `<connectionStrings configSource="connections.config"/>`.
  Copy `connections.config.sample` → `connections.config` on the deploy box.
- **AI gateway / API key** (AI-assistant branches) live in `web.config`
  `<appSettings>`: `AiGatewayUrl`, `AiApiKey` (blank in repo — filled on deploy),
  `AiUserId`, `AiModel`, optional `AiTemperature`/`AiMaxTokens`/`AiTopP`,
  `AiSystemPrompt`.
- **Login accounts** live in `App_Data/users.json` (NOT committed; generated on
  the deploy box with `tools/user_hash.py`). Missing/!valid file ⇒ every login
  returns `bad_credentials`.

## Data source

Queries target `[GPTPoCDB].[dbo].[_DefectNotice_FAB]` (Defect Notice) and
`[GPTPoCDB].[dbo].[Notes_Scrap_RawCat]` (Line Yield lookups) using full
three-part names and `System.Data.SqlClient`. Always use parameterized
`SqlCommand` (`@p0`, ...); never string-concat user input into SQL.

## Conventions & gotchas

- **Encoding is page-family specific.** The AI-assistant pages
  (`LineYield`, `DefectLessonLearn`, `AiChat`, `Home`) keep their `.cs` **pure
  ASCII** on purpose (comment: "encoding-safe") — Chinese lives in `web.config`
  / `.aspx` only, so a Big5/CP950 compile can't eat newlines. If a `.cs` header
  says keep-ASCII, all added code/comments MUST be ASCII. (The `Defectnotice*`
  pages, by contrast, already embed Chinese in `.cs`.)
- **`op`-based JSON API** (AI-assistant pages): the page is both UI and backend;
  the client POSTs `Page.aspx?op=login|list|upsert|delete|chat|lookupReason|...`
  and `Page_Load` dispatches via `HandleApi`. `Defectnotice*` pages are plain
  server-rendered `Page_Load`, no `op` API.
- **Auth returns HTTP 200, never 401.** `RequireAuth`/`HandleLogin` answer with
  `{ok:false,error:"needLogin"}` at status 200 on purpose, so IIS Classic
  doesn't tack on a `WWW-Authenticate` header and pop a Windows login box.
  Preserve this — don't "fix" it to return 401. Same reason the AI proxy remaps
  gateway `401/407` → `502`.
- **Tokens are an in-process `static` dict** (`_tokens`). Login on one worker +
  next call on another (IIS web garden / recycle) ⇒ spurious `needLogin`. Keep
  App Pool at 1 worker, or move to signed stateless tokens if this bites.
- **Duplicate page class name.** All `Defectnotice{,2,4}.aspx.cs` declare
  `public partial class GPTPoCDB_SampleSite_NotesTable`. Because ASP.NET
  batch-compiles a directory's pages into one assembly, deploying two of them
  side by side in the same folder can raise a duplicate-type compile error.
  Deploy the versions in separate folders/apps, or rename the class if merging.
- **AI chat proxy is non-streaming**: it buffers the whole gateway response and
  returns one JSON body. Don't forward `stream:true` without implementing SSE.

## Reusable helpers (Defect Notice)

- `GetIsoWeekYear(DateTime, out isoYear, out isoWeek)` — .NET 4.x-safe ISO week
  (no `System.Globalization.ISOWeek`).
- `ToShortToolLabel(section, tool)` — `NISACVD-xxx → N-xxx`, `SACVD-xxx → S-xxx`.
- 6-month time-window + `EQPID LIKE` SQL template.

## Git / branch workflow

- Develop on the branch you were assigned; **push only to that branch** unless
  told otherwise. `git push -u origin <branch>`; retry network failures with
  backoff (2s, 4s, 8s, 16s).
- Do **not** open a PR unless explicitly asked.
- Keep secrets out of commits (`connections.config`, real `AiApiKey`, real
  `users.json`).
