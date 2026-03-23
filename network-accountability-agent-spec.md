# Network Accountability Agent Spec

## Working Title
Network Accountability Agent

## Objective

Build a personal assistant agent that helps Khet consistently execute high-value networking activity by turning relationship context into daily action, reducing friction to outreach, and keeping the CRM state fresh enough to drive the right priorities.

This is not a generic CRM, not a general inbox triage assistant, and not a broad life admin tool.

The goal is simple: make sure the right follow-ups happen, even when Khet would naturally avoid them.

---

## Problem

Khet already has a People CRM built in Claude Code. It stores contacts as markdown files, can create or update records from conversation notes or transcripts, and can help identify who may need follow-up.

The problem is not access to relationship information. The problem is execution.

Networking is one of the highest-leverage activities for landing the next role, but it is also one of the most resisted. When left to self-manage, Khet is likely to choose other productive-feeling tasks over outreach and follow-up.

The assistant therefore needs to do more than answer questions. It needs to proactively:
- assign daily networking tasks
- nudge throughout the day
- reduce the effort required to complete outreach
- keep CRM records aligned with meaningful email activity
- help close loops and maintain momentum

---

## Non-Goals

This product is not intended to:
- act as a general email triage tool
- summarize the full inbox
- act as a general calendar assistant
- replace the underlying People CRM
- autonomously send messages in v1
- process text messages in v1
- become a broad personal productivity assistant
- manage all meetings, only networking-relevant ones later

---

## Product Definition

A Telegram-based accountability agent layered on top of the existing People CRM that converts relationship state into daily outreach tasks, nags until the right things are done, and lowers the activation energy by providing history, prioritization logic, and draft messages.

---

## Core User Need

The assistant should behave less like a search tool and more like a direct personal assistant.

It should:
- tell Khet who needs attention today
- tell Khet what reply or follow-up tasks outrank proactive outreach
- draft the actual message when asked
- remind Khet when tasks are incomplete
- accept quick updates and notes
- keep relationship state fresh enough that future recommendations are credible

---

## Scope

### Core v1
- morning networking task assignment
- top 3 daily tasks, stretch to 5 if needed
- direct interaction via Telegram
- history and priority explanation on demand
- outreach draft generation
- midday check-in
- late-afternoon push
- end-of-day closeout
- manual logging of interactions or notes
- simple task-state tracking
- skip / snooze / pause / correction handling

### v1.1
- Gmail-to-CRM reconciliation for tracked contacts
- automatic factual CRM updates from email
- proposed review flow for inferred next-step changes
- smarter resurfacing and escalation logic
- lightweight weekly scorecard

### Later
- help preparing for networking-relevant meetings
- contact-aware meeting prep
- text-message input stream
- autonomous low-risk sending with approval rules
- company/opportunity-aware prioritization
- intro-path suggestion logic
- deeper calendar and email integration

---

## User-Facing Responsibilities

The assistant should:
- tell Khet who to contact today
- tell Khet what reply or follow-up tasks outrank proactive outreach
- remind Khet through the day
- provide a draft email or text when requested
- provide quick history when requested
- explain why a task is prioritized now
- accept free-text corrections when the recommendation is wrong
- accept notes to log into CRM
- accept updates that correct CRM state
- allow the user to defer, skip, or pause suggestions without friction

---

## Background Responsibilities

The system should:
- review CRM contact records and identify follow-up candidates
- prioritize reply-required tasks ahead of proactive outreach
- track task state across the day
- roll tasks forward based on status and priority
- reconcile recent email activity for tracked contacts, later in v1.1
- update CRM records when meaningful interactions change relationship state
- keep the task queue aligned with current relationship reality

---

## Allowed Task Types

The assistant is responsible for relationship-execution tasks that directly move networking conversations or opportunities forward.

Primary task types:
1. Reply to an inbound message from a tracked contact
2. Follow up on an existing outreach or conversation
3. Complete an open loop or promised next step
4. Reconnect proactively with a strategically relevant contact
5. Log meaningful interaction notes when needed for decision quality

The assistant may later surface upcoming networking-relevant meetings and help prepare, but it is not a general calendar assistant in v1.

---

## Daily Behavior Loop

### Morning Assignment
At a defined morning time, send a Telegram message with today's top networking tasks.

Default:
- 3 primary tasks
- stretch mode up to 5
- absolute cap 5

Each task should include:
- contact name
- task type
- short “why now” reasoning

Example shape:
- David, reply, asked for resume yesterday
- Alicia, follow up, promised note still open
- Roman, reconnect, strategically relevant and stale

### Midday Check-In
Send a check-in that shows:
- what is complete
- what remains open
- an offer to help clear one task immediately

This should push toward action, not just status reporting.

### Late-Afternoon Push
If meaningful tasks remain open, send a more direct prompt to close at least one now.

### End-of-Day Closeout
Show:
- completed tasks
- skipped or paused items
- what will resurface tomorrow based on priority

---

## Interaction Model

The interaction model should be constrained and action-oriented, not fully open-ended chat.

### Task Actions
- `done`  
  User confirms they completed the task. This must be user-confirmed because the user is the sender.

- `draft`  
  Generate a draft message for the task.

- `history`  
  Return:
  - last interaction
  - open loop, if relevant
  - why now

- `why now`  
  Explain why this task is prioritized today versus others.

- `snooze`  
  Move the task to later today.

- `skip`  
  Skip the task for today only. It may resurface tomorrow based on priority. No explanation required.

- `pause`  
  Suppress the task for multiple days. Should request only a duration:
  - tomorrow
  - 3 days
  - 1 week
  - custom

- `make easier`  
  Reduce the lift. Examples:
  - shorter draft
  - softer ask
  - simpler text version
  - lower-commitment follow-up

- `wrong`  
  Accept free-text feedback describing what is wrong with the recommendation. This should be treated as high-value correction input and may update task logic, CRM state, or both.

### Global Actions
- `log`  
  Add a new interaction note, call note, or transcript summary to the CRM.

- `update`  
  Correct CRM state or relationship metadata.

---

## Priority Logic

Use a simple weighted-score approach in v1, not a black-box model.

Starting ranking inputs:
- reply required from tracked contact
- explicit open loop or promised next step
- recency of last meaningful interaction
- strategic relevance to current job search
- warmth / strength of relationship
- tie to a target company, role, or opportunity
- overdue follow-up status

Priority principle:
- people Khet owes a reply to rank first
- open loops outrank proactive reconnects
- proactive reconnects should still surface when strategically useful

The ranking model should be transparent enough that “why now” can explain a task in one or two lines.

---

## CRM Maintenance and State Reconciliation

The agent should support CRM maintenance without becoming an inbox triage tool.

### Boundary
Email is not the source product.
CRM remains the source of truth.
Gmail is one input stream that can update CRM state.

### Goal
Detect meaningful correspondence from tracked contacts that changes relationship state, follow-up needs, or next actions.

### v1.1 Behavior
For matched emails involving tracked contacts:
- detect whether the interaction is meaningful
- log factual state changes automatically when confidence is high
- propose inferred next-step changes for user review
- update last meaningful interaction date
- optionally bump a person into the task queue when a clear reply or promised action is needed

### Do Not
- summarize the full inbox
- auto-log every email
- treat all email as relationship-relevant
- become a general inbox assistant

### Logging Rule
Only log emails that materially change understanding, status, or action.

Examples:
- clear reply needed
- promised follow-up
- intro offered
- question asked
- meaningful update to relationship state

Do not clutter CRM with:
- quick acknowledgements
- trivial logistics
- low-signal noise

---

## Drafting Behavior

When asked for a draft, the assistant should:
- use CRM history and open loops
- keep tone aligned with Khet’s style
- generate either email or text as appropriate
- support quick revision via “make easier”
- learn from repeated edits over time, later, but not depend on a complex learning system in v1

The assistant should not send messages autonomously in v1.

---

## Tone and Personality

The assistant should sound:
- direct
- sarcastic but supportive
- pushy, not annoying
- concise
- not motivational
- unwilling to let Khet hide behind fake productivity

It should challenge avoidance without becoming theatrical or preachy.

Examples of the intended feel:
- call out obvious avoidance patterns
- push toward doing one thing now
- avoid generic encouragement
- avoid “great job” fluff

---

## Data Model Assumption

The assistant relies on the existing People CRM markdown record structure, which already includes enough relationship and interaction detail to support:
- history recall
- open-loop detection
- next-step suggestions
- prioritization inputs
- meaningful outreach drafting

The assistant should read from and write back to that markdown-based system rather than inventing a parallel datastore for relationship truth.

---

## Technical Architecture

### Front End
Telegram chat interface

### Build / Orchestration
Claude Code plus a lightweight orchestration layer

### Source of Truth
Existing People CRM markdown files

### Logic Split

Use deterministic code / scripts for:
- scheduling
- task selection
- weighted ranking
- task state tracking
- snooze / skip / pause logic
- reading and writing markdown
- day-end rollover
- email reconciliation rules

Use Claude for:
- draft generation
- history summaries
- “why now” explanations
- free-text correction interpretation
- reframing or simplifying tasks
- converting notes or transcripts into CRM log updates

---

## Success Metrics

Measure behavior change and meaningful networking execution, not vague effort.

Primary metrics:
- meaningful touches sent per week
- reply-required tasks cleared
- open loops closed
- days with at least 1 completed networking task
- warm conversations or meetings generated
- overdue follow-ups reduced

Secondary metrics:
- number of CRM updates captured
- quality/trust rate of recommendations
- number of wrong-task corrections over time
- reduction in stale CRM state for tracked contacts

---

## Design Principles

1. Behavior change matters more than elegance  
2. The assistant should reduce friction, not add ceremony  
3. Recommendations must be correct enough to earn trust  
4. Corrections should be easy and high-value  
5. The CRM should stay useful, not get polluted with noise  
6. The system should stay sharply focused on networking execution  
7. Any expansion should be earned by repeated real use

---

## Build Order Recommendation

### First Build
Implement the accountability loop:
- morning assignment
- task list
- history
- why now
- drafts
- midday reminder
- late-day push
- end-of-day closeout
- done / snooze / skip / pause / wrong
- manual log / update

### Second Build
Add Gmail-to-CRM reconciliation:
- matched tracked-contact emails
- meaningful interaction detection
- factual auto-updates
- proposed next-step changes
- task queue refresh when needed

### Third Build
Add meeting-prep and broader intelligence only after the core accountability loop is being used consistently.

---

## Final Product Standard

This assistant is successful if it reliably gets Khet to do the networking work they already know matters, without turning into a noisy dashboard, a generic inbox assistant, or another interesting project that avoids the real objective.

---

## Design Decisions Log

### March 22, 2026 — Initial Planning Session

#### Architecture
- **No Python bot, no Zapier, no n8n.** The entire system runs on Claude Code + Channels (Telegram plugin) + CronCreate.
- **Telegram Channels** handle two-way messaging. The bot receives and responds to commands. Paired to Khet's account with allowlist policy.
- **4 cron jobs** (morning 8am, midday 12pm, afternoon 4pm, EOD 6pm, weekdays only) trigger the daily behavior loop.

#### Data Model
- **No separate task files.** Contact files are the single source of truth. All state (ball in court, follow-up dates, next actions) lives in contact metadata. When Khet says "done," the contact file is updated immediately. The daily scan derives the task list from contact state — no intermediate task store.
- **Ball In Court** field added to all contacts: `Me / Them / Nobody`. This replaces both "open loop" and "reply required" as a single field. If Ball = Me, the agent parses the latest interaction to figure out what's owed.
- **Follow-up by** moved to top-level metadata (not buried in interaction entries). One canonical date, one place to read and update.
- **Next Action** field: one-line summary of what to do, only populated when Ball = Me. Saves the agent from re-inferring every morning.
- **Strategic relevance score dropped.** Tags (#job-search, #networking) plus company/relationship strength provide enough signal without a separate score.

#### Priority Rubric
1. Ball In Court = Me (highest)
2. Follow-up overdue
3. Follow-up due today/tomorrow
4. Active relationship + no contact in 2+ weeks
5. Warm relationship + no contact in 4+ weeks
6. Tagged #job-search + Dormant/Cold (lowest)
- Tiebreaker: prefer contacts where Last Initiated By = Them (reciprocity)
- Ball-in-my-court tasks always appear before proactive outreach

#### Dropped Features
- **"Make easier" command** — dropped. Khet just needs to do the thing. If requests become more layered, will revisit.
- **Task state files** — dropped. Contact files are the state. No separate tracking needed at 22 contacts.
- **Separate task system for non-networking work** — deferred. Keeping scope to networking execution only in v1.

#### Email Logging Rule
- Default to log all 1:1 emails from tracked contacts.
- Only skip: automated/transactional emails and single-word acknowledgments ("Thanks!", "Got it").
- Gmail MCP used to check for replies and update CRM state.

#### Git Strategy
- Each portfolio-worthy project gets its own repo
- ChiefOfStaff repo demonstrates: agent design, behavior change systems, prompt engineering, scheduled automation
- Contact files and personal data never touch GitHub
- `.gitignore` handles the boundary

#### Code vs LLM Decision
- At 22 contacts and 4 daily checks, LLM-only approach is fine (~$1-2/day).
- When contact count exceeds 50+ or more use cases are added, refactor scan/sort into a Python pre-processor that feeds a pre-digested briefing packet to the LLM.
- For now: no premature optimization.

---

### March 23, 2026 — Build Session & Architecture Corrections

#### Runtime Correction: Claude Code Terminal, Not Cowork
- **Cowork scheduled tasks cannot send Telegram messages.** Cowork lacks Telegram channel support — tasks fire but can't reach the bot.
- **Corrected runtime:** Claude Code terminal launched with `--channels plugin:telegram@claude-plugins-official` from `AI Workspace/`.
- **CronCreate** replaces Cowork scheduled tasks for scheduling. Session-only, expires after 3 days. Restart required every 3 days.
- Day-3 restart reminder included as a cron job.
- Cowork scheduled tasks deleted (useless without Telegram).

#### "Done" Command — Gmail-First Logging Flow
The "done" command now follows a two-step flow:
1. **Check Gmail first.** Search for sent emails to the contact since `Last Contact` date. If found, read the email and use its content to write the interaction log with real detail — no need to ask Khet.
2. **If no email found, ask.** The action happened outside email (text, call, meeting). Ask: how did you reach out? What happened? Any commitments or next steps? Wait for the response before logging.
3. Also check for inbound replies from the contact — there may be context Khet didn't mention.
4. Then update CRM: add interaction entry with real detail, update Ball In Court, Follow-up by, Next Action, Last Contact, Last Initiated By.

This was identified as a gap after the first live morning brief — Khet executed tasks but had to manually tell the agent what to log, and the agent didn't check Gmail for the actual email content.

#### Why Not a Skill for "Done"
Evaluated extracting the "done" flow into an agentman skill. Decided against it:
- The "done" flow is deeply contextual — needs today's brief, the full persona, CRM schema, and conversational back-and-forth when Gmail doesn't have the answer.
- Skills are stateless and standalone. The "done" command is a branch of CoS behavior, not an independent unit.
- The CLAUDE.md *is* the skill for the CoS. Individual commands within it are behavior branches, not separable tools.
- Skills are appropriate for genuinely independent, reusable tools (e.g., "generate networking email" any agent could use).

#### Folder Restructure
- **Learning moved into PersonalOS** (from `AI Workspace/Learning/` to `AI Workspace/PersonalOS/Learning/`).
- **Root-level PeopleCRM deleted** (legacy duplicate — PersonalOS version is canonical).
- **JobSearch** was already in PersonalOS. No move needed.
- **apply-job skill** uses relative paths — no update needed after moves.
- **README.md** updated with corrected folder structure and CoS runtime notes.

#### Updated Folder Structure
```
AI Workspace/                          ← launch dir for CoS
├── _shared/
│   ├── contacts/                      ← CRM data (OneDrive only, no git)
│   ├── career/                        ← Job search context
│   ├── references/                    ← Shared frameworks
│   └── about/                         ← Writing style, preferences
├── PersonalOS/                        ← Daily operating systems
│   ├── chief-of-staff/                ← CoS brain (git repo)
│   ├── PeopleCRM/                     ← Contact CRM, voice notes
│   ├── JobSearch/                     ← Job application workflow
│   └── Learning/                      ← Courses, certifications
├── Projects/                          ← Portfolio builds
│   ├── AI-In-Practice-Blogging/
│   └── SKOOL-Hackathon/
├── MarkerHeads/                       ← Client work
```

#### Startup Procedure
```bash
cd "AI Workspace"
claude --channels plugin:telegram@claude-plugins-official
```
Then tell the session to read `PersonalOS/chief-of-staff/CLAUDE.md` and set up cron jobs. Session must stay open for Telegram and crons to work. Restart every 3 days.
