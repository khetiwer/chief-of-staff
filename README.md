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
| State Persistence | 🔲 Building | Daily slate survives session restarts |
| Gmail Networking Scan | 🔲 Building | Auto-detects replies from tracked contacts |
| Calendar Awareness | 🔲 Building | Today's events in the morning brief |
| Meeting Prep (`prep`) | 🔲 Building | Pre-meeting brief from contact file |
| Inbox Triage (`triage`) | 🔲 Building | Full inbox scan via Gmail Triager skill |
| Relationship Health (`enrich`) | 🔲 Building | Proactive staleness scan across all contacts |
| Weekly Report (`weekly`) | 🔲 Building | Job search pipeline summary |

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

---

## Setup

### Prerequisites
- [Claude Code](https://docs.anthropic.com/claude-code) installed
- Gmail MCP configured
- Google Calendar MCP configured (Phase 3+)
- Telegram bot configured (see `.claude/settings.local.json`)

### Contact Files
Contacts live in `_shared/contacts/` as markdown files (`firstname-lastname.md`). Each file follows the schema in `SPEC.md`. The agent reads these files — it does not write to any database.

### Key Paths (configure for your setup)
```
Contact files:   [your-workspace]/_shared/contacts/
Writing style:   [your-workspace]/_shared/about/[your-name]-writing-style.md
Career context:  [your-workspace]/_shared/career/
```

Update the paths in `CLAUDE.md` to match your directory structure.

### First Run
```bash
cd [your-chief-of-staff-directory]
claude --channels plugin:telegram@claude-plugins-official
```

Send `brief` in Telegram to run the first morning brief.

---

## What Gets Published vs. What Stays Private

**Published (this repo):** `CLAUDE.md`, `README.md`, `SPEC.md`, `PLAN.md`, `.gitignore`, `.claude/settings.local.json`

**Never published (gitignored):** `state/`, `sessions/`, `reports/`

**Kept separate (not in this repo):** Your contact files, writing style guide, career context — these live in your personal `_shared/` directory outside this repo.

---

## Documentation

- `README.md` — This file. What/why/setup/usage.
- `SPEC.md` — Architecture decisions, module behavioral specs, data schemas.
- `PLAN.md` — Living build plan. Task list, status, what's next.
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

Active development. See `PLAN.md` for current build phase and task list.
