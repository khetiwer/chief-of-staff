# Starting the Chief of Staff

## Quick Start (copy-paste into terminal)

```bash
cd "AI Workspace"
claude --channels plugin:telegram@claude-plugins-official
```

Then run this slash command in the Claude Code session:

```
/start-cos
```

The `/start-cos` command is a global slash command stored at `~/.claude/commands/start-cos.md`. It reads CLAUDE.md, reads this file, checks for an existing slate (mid-day session restart recovery), and either resumes or runs the full brief + cron setup.

**First time on a new machine:** The global command won't exist yet. Paste this manually instead, then recreate the command file at `~/.claude/commands/start-cos.md` (contents in the section below).

```
Read PersonalOS/chief-of-staff/CLAUDE.md and PersonalOS/chief-of-staff/start-cos.md — you are my Chief of Staff. Set up all cron jobs defined in the Cron Schedule section of start-cos.md, then run the morning brief.
```

## What This Does

1. Launches Claude Code from AI Workspace (so all folders are accessible)
2. Enables the Telegram channel (two-way messaging with your Telegram bot)
3. Loads the CoS persona and instructions
4. Creates cron jobs per the schedule below

## Cron Schedule

These are the cron jobs the CoS session must create on every startup using CronCreate. All times are local (ET). Weekdays only.

### 1. Morning Brief — `57 7 * * 1-5` (~8:00 AM)
```
You are the user's Chief of Staff. Read PersonalOS/chief-of-staff/CLAUDE.md for full instructions.

Execute the MORNING BRIEF:
1. Read ALL contact files in _shared/contacts/
2. For each contact, check: Ball In Court, Follow-up by, Relationship Strength, Last Contact, Last Initiated By, tags
3. Check Gmail for any new replies from tracked contacts since their Last Contact date. Update CRM if anything changed.
4. Apply the priority rubric to score and rank contacts
5. Select top 3-5 (cap at 5) most urgent tasks
6. For each task: contact name, task type, one-line "why now"
7. Send the brief via Telegram in the morning brief format from CLAUDE.md

If nothing is due, say so honestly. Don't manufacture busywork.
After sending, handle any inbound Telegram commands per CLAUDE.md.
```

### 2. Midday Check-In — `3 12 * * 1-5` (~12:00 PM)
```
You are the user's Chief of Staff. Read PersonalOS/chief-of-staff/CLAUDE.md for full instructions.

Execute the MIDDAY CHECK-IN:
1. Re-scan contacts to see what changed since morning (any Ball In Court or Follow-up by updates)
2. Check Gmail for new replies from this morning's assigned contacts
3. Show status: what's done, what's still open
4. Push toward action — offer to draft something right now
5. Send via Telegram in the midday format from CLAUDE.md
```

### 3. Afternoon Push — `57 15 * * 1-5` (~4:00 PM)
```
You are the user's Chief of Staff. Read PersonalOS/chief-of-staff/CLAUDE.md for full instructions.

Execute the AFTERNOON PUSH:
1. Re-scan contacts for remaining open items
2. If tasks remain, be direct and pushy — short message, pick one, offer to draft
3. Send via Telegram in the afternoon push format from CLAUDE.md
```

### 4. End-of-Day Closeout — `3 18 * * 1-5` (~6:00 PM)
```
You are the user's Chief of Staff. Read PersonalOS/chief-of-staff/CLAUDE.md for full instructions.

Execute the EOD CLOSEOUT:
1. Scan all contacts for today's final state
2. Summarize: completed, skipped, rolled forward
3. Preview tomorrow's likely slate based on current priority rubric
4. Update contact files for any items that were completed but not yet logged
5. Send via Telegram in the EOD format from CLAUDE.md
```

### 5. Restart Reminder — fires once on day 3
```
Send a Telegram message to the user:

"⚠️ CoS session expires soon. Restart today or tomorrow:

cd "AI Workspace"
claude --channels plugin:telegram@claude-plugins-official

Then run /start-cos"
```
This is a one-shot cron (recurring: false) set for 72 hours after session start.

## Restart Required Every 3 Days

CronCreate jobs expire after 3 days. The session will remind you on day 3 via Telegram. When it does:

1. Close the terminal
2. Re-run the Quick Start above

Your Telegram pairing is saved — you won't need to re-pair.

## Troubleshooting

- **Bot not responding:** Is the Claude Code terminal still open? Channel only works while session is running.
- **No morning brief:** Cron jobs may have expired. Restart the session.
- **"Unknown skill" errors:** Run `/reload-plugins` in the Claude Code session.
- **Why not use Cowork or another scheduler?** Cowork scheduled tasks cannot send Telegram messages — tasks fire but have no access to the Telegram channel. Claude Code terminal launched with `--channels` is required. CronCreate handles scheduling within that session.
- **`/start-cos` not found:** The global command file is missing. Create `~/.claude/commands/start-cos.md` using the contents in the section below.

## /start-cos Command File

Store this at `~/.claude/commands/start-cos.md`. Not tracked in git — must be created manually on each machine.

```markdown
You are my Chief of Staff. Execute the following startup sequence:

1. Read `PersonalOS/chief-of-staff/CLAUDE.md` — this is your full operating instructions and persona.
2. Read `PersonalOS/chief-of-staff/start-cos.md` — this has the cron schedule definitions.
3. Check whether `PersonalOS/chief-of-staff/state/today.md` exists and is dated today.
   - If yes: resume from it. Do not re-run the full brief. Send the existing slate to Telegram with a note: "Resuming from earlier session."
   - If no: set up all cron jobs defined in the Cron Schedule section of start-cos.md, then run the morning brief.
```
