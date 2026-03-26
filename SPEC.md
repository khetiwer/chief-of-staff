# Personal COS — Technical Specification

This document covers architecture decisions, module behavioral specs, data schemas, and integration requirements. It is the "why we built it this way" document. For what's being built and task status, see `PLAN.md`. For setup and usage, see `README.md`.

---

## Architecture Overview

### Single Agent, Modular CLAUDE.md

All behavior lives in one `CLAUDE.md`. Modules are clearly demarcated sections. The agent is invoked once; it reads all relevant state at startup and routes commands to the appropriate module behavior.

**Why not separate agents?** The value comes from cross-domain connections — knowing a meeting contact is also someone with an overdue follow-up. Split agents can't make those connections. See `PLAN.md` Decision 1.

### State Layer

Three files carry context between sessions. All are gitignored.

```
state/today.md      — Daily slate. Written at brief, updated through day, archived at EOD.
state/goals.md      — Job search goals and pipeline targets.
sessions/YYYY-MM-DD.md  — Daily log. Written at EOD closeout.
reports/YYYY-MM-DD.md   — Weekly pipeline summaries. Written by `weekly` command.
```

### Contact CRM

Contact files live in `_shared/contacts/` — outside this repo. One markdown file per person (`firstname-lastname.md`). Schema defined below. The agent reads these files; it does not write to a database.

---

## Data Schemas

### Contact File Schema

```markdown
# [Full Name]

**Tags:** #professional #networking #job-search

## Key Info

| Field    | Details          |
|----------|------------------|
| Company  |                  |
| Role     |                  |
| Email    |                  |
| LinkedIn |                  |
| Phone    |                  |

**Relationship Strength:** [Active/Warm/Dormant/Cold]
**Domain Trust:** [categories]
**Last Contact:** YYYY-MM-DD
**Last Initiated By:** [Me/Them/Mutual]
**Ball In Court:** [Me/Them/Nobody]
**Follow-up by:** YYYY-MM-DD
**Next Action:** [one-line summary, only when Ball = Me]

## Relationship Context

[How we met / background]

## Interactions

### YYYY-MM-DD - [Brief Title]

- **Type:** Professional / Personal
- **Notes:**
  - [Details]
- **Follow-up by:** YYYY-MM-DD *(optional)*
```

**Key fields for scanning (metadata pass):**
- `Ball In Court` — primary signal for daily brief
- `Follow-up by` — canonical date for action
- `Relationship Strength` — used by `/enrich` staleness tiers
- `Last Contact` — used by `/enrich` staleness calculation
- `Email` — used by Gmail networking scan

### `state/today.md` Schema

```markdown
# Today's Slate — YYYY-MM-DD

## Morning Brief
Generated: HH:MM

| # | Name | Priority | Why Now | Status |
|---|------|----------|---------|--------|
| 1 | [Name] | P1-overdue | [one-line reason] | 🔲 open |
| 2 | [Name] | P1-due-today | [one-line reason] | ✅ done |
| 3 | [Name] | P3-due-soon | [one-line reason] | → skipped |

## Gmail Scan
[Results or "No new replies from tracked contacts"]

## Calendar
[Today's events or "No calendar events today"]

## EOD Summary
*(Written at closeout)*
Completed: N | Skipped: N | Rolled: [names]
```

**Status values:**
- `🔲 open` — not yet actioned
- `✅ done` — marked done
- `→ skipped` — skipped today
- `⏭ snoozed` — snoozed with date

### Session Log Schema (`sessions/YYYY-MM-DD.md`)

```markdown
# Session Log — YYYY-MM-DD

## Morning Brief
- Sent: HH:MM
- Slate: [N] items ([N] ball-in-court, [N] overdue, [N] due-soon)
- Gmail scan: [N] auto-updates / none

## Actions Taken
- [Name]: done — [brief description]
- [Name]: skipped
- [Name]: draft generated

## EOD
- Completed: [N]
- Skipped: [N]
- Rolled to tomorrow: [names]
- Notes: [anything notable]
```

---

## Module Behavioral Specs

### Module 1: Networking (Live)

**Priority rubric (scoring order):**
1. Ball In Court = Me (always first)
2. Follow-up overdue (date has passed)
3. Follow-up due today or tomorrow
4. Active relationship + no contact in 2+ weeks
5. Warm relationship + no contact in 4+ weeks
6. Tagged #job-search + Dormant/Cold (low urgency)

**Tiebreaker:** Prefer contacts where `Last Initiated By: Them`

**Brief cap:** 3 primary tasks. Stretch to 5 only if 4-5 genuinely urgent items exist. Absolute cap: 5.

**Contact file read strategy:** Scan metadata only for all contacts. Read full files only for contacts in the top 5.

### Module 2: State Persistence (Phase 1)

**Morning brief behavior:**
1. Check if `state/today.md` exists and is dated today
   - If yes: resume from existing slate (session restart recovery)
   - If no: run full brief scan, write new `state/today.md`
2. Brief sends to Telegram
3. `today.md` status column starts as `🔲 open` for all items

**done/skip/snooze behavior:**
- Update the matching row's Status in `today.md` in place
- Write the contact file update (existing behavior)

**Midday + afternoon check-ins:**
1. Read `state/today.md`
2. Count open vs. done vs. skipped
3. Report from file, not from memory

**EOD closeout:**
1. Read `state/today.md`
2. Generate summary (completed, skipped, rolled)
3. Write `sessions/YYYY-MM-DD.md`
4. Clear `state/today.md` (reset for tomorrow)
5. Send Telegram summary

### Module 3: Gmail Networking Scan (Phase 2)

**Trigger:** Runs as part of morning brief, before building the slate.

**Scope:** Only contacts with an email address in their Key Info table. Never touches the full inbox.

**Process:**
1. Read all contact files' metadata (email + Ball In Court + Last Contact)
2. For contacts where Ball In Court = Them or Nobody AND email is known: call `gmail_search_messages` with `from:[email] after:[last-contact-date]`
3. If reply found:
   - Update contact file: Last Contact, Last Initiated By: Them, Ball In Court: Me, add interaction entry
   - Add to brief preamble: "Auto-detected: [Name] replied — CRM updated"
4. If no replies: one-line note "No new replies from tracked contacts"

**What it does NOT do:** Read email body content beyond what's needed to confirm a reply exists. Does not triage, categorize, or summarize non-networking emails.

### Module 4: Calendar Awareness (Phase 3)

**Trigger:** Runs as part of morning brief.

**Process:**
1. Call `gcal_list_events` for today
2. For each event with a known attendee name: check if they're in the contact CRM
3. If match found: add to brief — "12:00pm — Lunch with [Name] (contact file available — `prep [name]` for talking points)"
4. If no events: "No calendar events today"

**`prep [name]` command:**
1. Read ONE contact file
2. Surface: last interaction, open loops, any promises made, relationship context
3. Draft 3-4 talking points appropriate to the relationship type
4. Does NOT draft an email — drafts talking points only
5. Sends to Telegram

### Module 5: Inbox Triage (Phase 4)

**Trigger:** `triage` command (manual invoke or scheduled)

**Behavior:** Delegates entirely to the `personal-gmail-triager` Agentman skill. No custom logic. The skill handles categorization, draft creation, newsletter summaries, spam flagging, and self-improving preferences.

**Morning brief integration:** Brief ends with a nudge if inbox hasn't been triaged that day: "Inbox not checked yet — send `triage` when ready"

### Module 6: Enrich / Relationship Health (Phase 5)

**Staleness tiers:**
| Relationship Strength | No-contact threshold |
|---|---|
| Active | 14 days |
| Warm | 30 days |
| Dormant | 60 days |
| Cold | Not monitored |

**`enrich stale` behavior:**
1. Read metadata for all contacts (Relationship Strength + Last Contact only — no full file reads)
2. Calculate days since last contact for each
3. Flag contacts past their tier threshold
4. For flagged contacts: read full file to confirm status and generate action suggestion
5. Return Telegram-formatted report: name, relationship strength, days since contact, suggested action

**`enrich [name]` behavior:**
1. Read ONE contact file
2. Assess staleness and relationship health
3. Return: last contact date, days elapsed, staleness tier, recommended next action

**Weekly automated check:** Runs Monday 9am via cron. Equivalent to `enrich stale` but limited to contacts where `Ball In Court = Nobody` (i.e., not already flagged by the daily brief).

### Module 7: Draft Logging (Phase 6)

**Trigger:** Whenever `draft [name]` is executed.

**Behavior:**
1. Generate draft (existing behavior)
2. Send to Telegram (existing behavior)
3. **NEW:** Add interaction entry to contact file immediately:
   ```markdown
   ### YYYY-MM-DD - Draft generated

   - **Type:** Professional
   - **Notes:**
     - Draft generated for [reason / open loop]
     - Draft text: "[full draft text]"
   ```

**Why:** Draft is invisible to future sessions without this log. This closes the "what did I send?" gap.

### Module 8: Weekly Pipeline Report (Phase 7)

**Trigger:** `weekly` command or Friday scheduled run

**Process:**
1. Read `sessions/` logs from past 7 days
2. Read contact metadata (not full files) for pipeline summary
3. Generate report:
   - Contacts reached this week (done actions)
   - Ball-in-court backlog (Ball In Court = Me, count)
   - New contacts added
   - Chronically rolled items (skipped 3+ times)
   - Stalled warm relationships (Warm + no contact in 3+ weeks)
   - Completion rate (done / total surfaced)
4. Save to `reports/YYYY-MM-DD.md`
5. Send Telegram summary

---

## Integration Requirements

| Module | MCP / Service | Permissions needed |
|---|---|---|
| Gmail Networking Scan | Gmail MCP (native) | `gmail_search_messages`, `gmail_read_message` |
| Inbox Triage | `personal-gmail-triager` Agentman skill | Same Gmail MCP + Zapier for threaded drafts |
| Calendar Awareness | Google Calendar MCP | `gcal_list_events` |
| Meeting Prep | Google Calendar MCP | `gcal_get_event` |
| Telegram | Telegram plugin MCP | `reply`, `react`, `edit_message` |

---

## Context Window Strategy

| Operation | Files Read | Notes |
|---|---|---|
| Morning brief | `state/today.md` + contact metadata for all + full files for top 5 | Metadata pass first, full reads only for surfaced contacts |
| `/enrich` | Contact metadata for all + full files for flagged only | Same discipline |
| `/draft`, `/history`, `/prep`, `/why` | ONE contact file | Single-contact commands never need full CRM |
| `/weekly` | Session logs (7 days) + contact metadata | Structured logs are short |
| EOD closeout | `state/today.md` | Already in context; just writes session log |
| `triage` | Delegated to skill | Skill manages its own context |

**Rule:** Never load full interaction history for more than 5 contacts in a single operation. Scan metadata → flag → read full file only for flagged.

---

## Decision Log

| Decision | Chosen Approach | Alternatives Considered | Reason |
|---|---|---|---|
| Agent architecture | One agent, modular CLAUDE.md — no external orchestration | Multiple specialized agents; Python bot; Zapier; n8n | Cross-domain connections require shared context; external orchestration adds infra with no benefit at this scale |
| Gmail triage | Two-track (networking scan inline + triage via skill) | One unified Gmail module | Scope mismatch: targeted contact check ≠ full inbox management |
| State storage | Markdown files | JSON, SQLite | Readable, editable, gitignore-able, no dependencies |
| Contact storage | `_shared/contacts/` outside repo | Inside repo | Keeps personal data separate from publishable code |
| Weekly report | `weekly` command from session logs | Real-time contact scan | Session logs are already structured; avoids re-scanning full CRM |
| Work COS | Separate future agent | Extend this agent | Work and personal context should not bleed; credentials differ |
| `done` command flow | Gmail-first: check sent mail before asking user | Ask user immediately | Gap found after first live brief — sent email contains the full interaction detail; asking user is redundant when Gmail has the answer |
| `done` command as skill | Kept inline in CLAUDE.md | Extract to Agentman skill | Flow is deeply contextual — requires today's brief, CRM schema, and conversational fallback when Gmail has no match. Skills are stateless; this is a behavior branch, not a reusable tool |
