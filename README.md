# Personal Chief of Staff

A Claude Code-powered personal COS that proactively manages networking, calendar, and inbox via Telegram. One interface. One morning brief. Everything you need to be doing, surfaced before you ask.

---

## What It Does

Every morning, this agent scans your contact CRM, checks your calendar, and scans for replies from tracked contacts in Gmail. It delivers a single Telegram message with:

- **Networking slate** — who you owe a follow-up, ranked by urgency
- **Calendar** — what's on today and who you're meeting
- **Inbox signals** — replies from tracked contacts auto-detected and CRM updated

Throughout the day you interact by replying to Telegram. At end of day, it logs what happened and rolls forward anything unfinished.

---

## Philosophy

> The intelligence lives at the seam between domains.

A brief that only knows your contacts doesn't know you have lunch with one of them tomorrow. A system that only manages your calendar doesn't know that person owes you a follow-up. This agent holds all the context and connects the dots.

It does not wait to be asked. It pushes.

---

## Modules

| Module | Status | Description |
|---|---|---|
| Networking | ✅ Live | Contact CRM, daily brief, follow-up tracking |
| State Persistence | ✅ Live | Daily slate survives session restarts |
| Gmail Networking Scan | ✅ Live | Auto-detects replies from tracked contacts |
| Calendar Awareness | ✅ Live | Today's events in the morning brief |
| Meeting Prep (`prep`) | ✅ Live | Pre-meeting brief from contact file |
| Inbox Triage (`triage`) | ✅ Live | Full inbox scan via Gmail Triager skill |
| Relationship Health (`enrich`) | ✅ Live | Proactive staleness scan across all contacts |
| Weekly Report (`weekly`) | ✅ Live | Pipeline summary from session logs |
| Goals Tracking | ✅ Live | Weekly targets wired into brief and weekly report |

---

## Commands

### Task Commands
| Command | What It Does |
|---|---|
| `done [name]` | Mark follow-up complete, update CRM |
| `draft [name]` | Generate a draft message (not sent — review first) |
| `prep [name]` | Pre-meeting talking points from contact file |
| `history [name]` | Last interaction + ball in court status |
| `why [name]` | Why this person is prioritized today |
| `skip [name]` | Skip for today |
| `snooze [name] [duration]` | Suppress for N days/weeks |
| `wrong [name] [feedback]` | Correct the agent's understanding |

### Global Commands
| Command | What It Does |
|---|---|
| `brief` | Re-send the morning brief on demand |
| `brief quick` | Ball-in-court items only |
| `triage` | Full inbox scan (Important / Newsletter / Spam / FYI) |
| `enrich stale` | Scan all contacts for relationships going cold |
| `enrich [name]` | Staleness check for one contact |
| `weekly` | Job search pipeline summary for the past 7 days |
| `log [name] [notes]` | Add interaction entry to contact file |
| `update [name] [field] [value]` | Update CRM metadata |
| `status` | Today's task status (complete / open / skipped) |
| `met [name]` | Log a completed networking conversation, increments weekly count |
| `applied [company]` | Log a job application, increments weekly count |
| `post [content\|free]` | Log a LinkedIn post, increments weekly count |
| `habits [items]` | Log completed habits for the day |

---

## Setup

### Prerequisites
- [Claude Code](https://docs.anthropic.com/claude-code) installed
- Gmail MCP configured
- Google Calendar MCP configured (Phase 3+)
- Telegram bot configured (see `.claude/settings.local.json`)

### Contact Files
Contacts live in `_shared/contacts/` as markdown files (`firstname-lastname.md`). The agent reads these files — it does not write to any database. The full contact file schema is documented in `SPEC.md`; for a standalone PeopleCRM setup, that schema belongs in its own README.

### Key Paths (configure for your setup)
```
Contact files:   [your-workspace]/_shared/contacts/
Writing style:   [your-workspace]/_shared/about/[your-name]-writing-style.md
Career context:  [your-workspace]/_shared/career/
```

Update the paths in `CLAUDE.md` to match your directory structure.

### First Run

**1. Allow PowerShell scripts** (once per machine):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**2. Add the `cos` shortcut to your PowerShell profile** (`~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`):
```powershell
function cos {
    & "[your-path]\chief-of-staff\scripts\launch-cos.ps1"
}
```

**3. Launch:**
```powershell
cos
```

The script kills any zombie bun processes before starting, then launches Claude from the correct working directory with the Telegram channel enabled. Open a new PowerShell window after editing the profile for the shortcut to take effect.

Then type `/start-cos` in the Claude Code session and send `brief` in Telegram to run the first morning brief.

See `start-cos.md` for the full launch reference.

---

## What Gets Published vs. What Stays Private

**Published (this repo):** `CLAUDE.md`, `README.md`, `SPEC.md`, `.gitignore`, `.claude/settings.local.json`, `scripts/`

**Never published (gitignored):** `state/`, `sessions/`, `reports/`

**Kept separate (not in this repo):** Your contact files, writing style guide, career context — these live in your personal `_shared/` directory outside this repo.

---

## Documentation

- `README.md` — This file. What/why/setup/usage.
- `SPEC.md` — Architecture decisions, module behavioral specs, data schemas.
- `CLAUDE.md` — The agent's full operating instructions. Start here to understand behavior.

---

## Guardrails

- **Never sends email** — only creates drafts for your review
- **Never deletes contact data** — without explicit written confirmation
- **Never modifies calendar** — without confirmation
- **Never shares contact information** — CRM content stays in session
- **Draft logging** — every generated draft is logged in the contact file

---

## Status

All core modules live. See `SPEC.md` for architecture details and `CLAUDE.md` for the full behavioral specification.
