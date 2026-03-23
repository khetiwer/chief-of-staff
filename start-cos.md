# Starting the Chief of Staff

## Quick Start (copy-paste into terminal)

```bash
cd "C:\Users\kheti\OneDrive\Documents\AI Workspace"
claude --channels plugin:telegram@claude-plugins-official
```

Then paste this into the Claude Code session:

```
Read PersonalOS/chief-of-staff/CLAUDE.md — you are my Chief of Staff. Set up the daily cron jobs and run the morning brief.
```

## What This Does

1. Launches Claude Code from AI Workspace (so all folders are accessible)
2. Enables the Telegram channel (two-way messaging with Alfred bot)
3. Loads the CoS persona and instructions
4. Creates 4 cron jobs: morning 8am, midday 12pm, afternoon 4pm, EOD 6pm (weekdays)

## Restart Required Every 3 Days

CronCreate jobs expire after 3 days. The session will remind you on day 3 via Telegram. When it does:

1. Close the terminal
2. Re-run the Quick Start above

Your Telegram pairing is saved — you won't need to re-pair.

## Troubleshooting

- **Bot not responding:** Is the Claude Code terminal still open? Channel only works while session is running.
- **No morning brief:** Cron jobs may have expired. Restart the session.
- **"Unknown skill" errors:** Run `/reload-plugins` in the Claude Code session.
