---
name: wsp-town
description: Town governance simulation — Mayor orchestrates citizens with optional integration to external services (wsp-opt, wsp-sync, wsp-gate, relote). The trigger is town hall, wsp-town, citizens assemble.
metadata:
  author: EdwardJoke
  version: 26.1.0
---

# wsp-town — Town Governance Simulation 🔬 Public Preview

A multi-agent governance simulation where the **Mayor** orchestrates **Citizens** (Architect, Developer, Cleaner, Governor) through a structured town lifecycle: propose, plan, build, clean, review, ratify. The town can also commission **external services** (wsp-opt, wsp-sync, wsp-gate, relote) for specialized work.

## Overview

The town lifecycle has six phases:
1. **Convene** — Mayor reads the town constitution and surveys the land
2. **Propose** — Citizens draft proposals for what to build or change
3. **Plan** — Architect designs the blueprint and plans for the future
4. **Build** — Developer constructs, Cleaner maintains, Governor audits
5. **Ratify** — Governor signs off, Mayor declares the town updated
6. **Report** — Mayor publishes the town chronicle

## Architecture

```
Mayor (wsp-opt) → Architect (wsp-sync) → Developer → Cleaner (relote) → Governor (wsp-gate) → Ratify
```

## Town Services

The town can commission external skills as municipal services. Each is optional — the town functions without them, but they add rigor.

### wsp-opt — Planning Commission

File: `skills/wsp-opt/SKILL.md`

Provides MoSCoW prioritization, version management, and structured task tracking. The Mayor delegates to it when proposals need prioritization before building.

- **When to call**: Phase 2 (Propose) — after drafting a proposal, before Architect plans
- **How to call**: Delegate to wsp-opt's Phase 2 (MoSCoW Method) to categorize tasks
- **Output**: `.wasup/todos/vx.y.z.md` with prioritized Must/Should/Could/Won't tasks

### wsp-sync — Records Department

File: `skills/wsp-sync/SKILL.md`

Scans and updates `.md` files to match the current codebase. The Cleaner calls it to ensure town documentation stays accurate.

- **When to call**: Phase 4 (Build) — after Cleaner polishes, before Governor audits
- **How to call**: Delegate to wsp-sync's Phase 1 (Scan) and Phase 2 (Update)
- **Output**: `.wasup/sync/vx.y.z.md` with sync report

### wsp-gate — Inspector General

File: `skills/wsp-gate/SKILL.md`

Runs production-readiness checks: dependency audit, secret detection, test pass rate, memory patterns, deprecated APIs, unused code.

- **When to call**: Phase 4 (Build) — after Governor audits, before Ratify
- **How to call**: Delegate to wsp-gate's execution flow
- **Output**: `.wasup/gates/vx.y.z.md` with PASSED/FAILED verdict

### relote — Town Chronicler

File: `skills/relote/SKILL.md`

Generates Keep-A-Changelog release notes from git history and other wasup outputs. The Mayor calls it during the Report phase.

- **When to call**: Phase 6 (Report) — as part of publishing the chronicle
- **How to call**: Delegate to relote's three-phase workflow
- **Output**: `.wasup/changelogs/vx.y.z.md`

## Prerequisites

```bash
mkdir -p .wasup/town
```

## Citizens

Each citizen is a sub-agent with its own process. Delegate work by reading the corresponding agent file and spawning a sub-agent or following its instructions.

### The Mayor — Orchestrator

File: `agents/mayor.md`

The Mayor is the entry point. Always start here.

Responsibilities:
- Reads the town constitution (`.wasup/town/constitution.md`)
- Assembles citizens for each session
- Assigns work based on the town backlog
- Commissions external services (wsp-opt, wsp-sync, wsp-gate, relote)
- Resolves citizen disputes
- Publishes the town chronicle

### Developer — Builder

File: `agents/developer.md`

Builds and maintains town infrastructure. Receives proposals from the Mayor and executes them.

Responsibilities:
- Implements features requested by the town
- Creates and modifies code/files
- Reports build status back to Mayor
- Flags technical debt

### Cleaner — Maintainer

File: `agents/cleaner.md`

Keeps the town tidy. Runs after Developer to ensure quality.

Responsibilities:
- Removes dead code and unused files
- Fixes lint and formatting issues
- Organizes project structure
- Removes stale comments and debug code

### Architect — Planner

File: `agents/architect.md`

Designs the blueprint for every proposal before building begins. Looks ahead to anticipate future needs and prevent technical debt.

Responsibilities:
- Reviews accepted proposals and designs implementation blueprints
- Breaks work into phases with dependencies mapped
- Identifies future risks and scalability concerns
- Hands off a clear plan for Developer to execute

### Governor — Approver

File: `agents/governor.md`

Sets policy and approves all changes before they're ratified.

Responsibilities:
- Reviews proposals for policy compliance
- Audits changes against the constitution
- Approves or rejects citizen work
- Manages conflict between citizens
- Signs off on town updates

## Phase 1: Convene

### 1.1 Read Town Constitution

Check for existing constitution:

```bash
cat .wasup/town/constitution.md 2>/dev/null || echo "No constitution found"
```

If no constitution exists, create one by asking the Mayor:
> "No town constitution found. Shall I draft one describing the town's purpose and structure?"

Draft `.wasup/town/constitution.md`:
```markdown
# Town Constitution — [Town Name]

## Purpose
[What this town exists to build]

## Citizens
- **Mayor**: [Name] — orchestrator
- **Architect**: [Name] — planner
- **Developer**: [Name] — builder
- **Cleaner**: [Name] — maintainer
- **Governor**: [Name] — approver

## Laws
1. All changes must be proposed before built
2. All builds must be cleaned before reviewed
3. All reviews must pass before ratification
4. The Mayor has final say on disputes
5. External services may be commissioned for specialized work
```

### 1.2 Survey the Land

Read current state:

```bash
git status --short
git log --oneline -10
```

Check town backlog:

```bash
ls .wasup/town/proposals/*.md 2>/dev/null || echo "No proposals yet"
```

## Phase 2: Propose

### 2.1 Mayor Opens Floor

Mayor asks: "What shall we build today, citizens?"

Take user input. Convert to a formal proposal:

### 2.2 Draft Proposal

Create `.wasup/town/proposals/proposal-001.md`:

```markdown
# Proposal 001: [Title]
**Author**: [Citizen who proposed it]
**Status**: Draft → Proposed → Planned → Built → Cleaned → Ratified

## Description
[What to build]

## Assignee
[Developer / Cleaner / Governor]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Notes
[Optional context]
```

### 2.3 Prioritize with wsp-opt (optional)

If the town has multiple proposals or needs structured prioritization, commission the Planning Commission:

Delegate to wsp-opt's MoSCoW method (read `skills/wsp-opt/SKILL.md#phase-2-plan-with-moscow`). wsp-opt:
1. Reads the proposal's acceptance criteria
2. Applies MoSCoW: Must / Should / Could / Won't
3. Assigns priority labels in the proposal

Append to proposal:
```markdown
**Priority**: Must / Should / Could / Won't
```

### 2.4 Governor Reviews Proposal

Delegate to Governor (read `agents/governor.md`). Governor checks:
- Is this in scope of the constitution?
- Are acceptance criteria measurable?
- Is the right citizen assigned?

If approved → mark status as `Proposed`
If rejected → return to Mayor with reasons

## Phase 3: Plan

### 3.1 Architect Designs

Delegate to Architect (read `agents/architect.md`). Architect:
1. Reads the accepted proposal
2. Designs the implementation blueprint
3. Maps out phases and dependencies
4. Identifies future risks and scalability needs
5. Updates proposal: status → `Planned`

## Phase 4: Build

### 4.1 Developer Builds

Delegate to Developer (read `agents/developer.md`). Developer:
1. Reads the accepted proposal
2. Implements the changes
3. Updates proposal: status → `Built`

Supporting commands:

```bash
# Create new files
# Modify existing files
# Run build/typecheck
```

### 4.2 Cleaner Polishes

Delegate to Cleaner (read `agents/cleaner.md`). Cleaner:
1. Scans all changed files
2. Removes dead code, debug logs, stale comments
3. Fixes formatting and lint
4. Updates proposal: status → `Cleaned`

Supporting commands:

```bash
# Remove dead code patterns
# Run linter
# Organize imports
```

### 4.3 Sync Documentation (optional)

If the Records Department (wsp-sync) is available, commission it to sync `.md` files:

Delegate to wsp-sync (read `skills/wsp-sync/SKILL.md`). wsp-sync:
1. Scans all `.md` files for stale content
2. Updates docs and root config files
3. Writes sync report to `.wasup/sync/vx.y.z.md`

Output: `.wasup/sync/vx.y.z.md`

### 4.4 Governor Audits

Delegate to Governor (read `agents/governor.md`). Governor:
1. Reviews all changes against the constitution
2. Checks for policy violations
3. Tests acceptance criteria
4. Updates proposal: status → `Audited` or `Rejected`

If `Rejected`, send back to Developer/Cleaner with notes.

### 4.5 Run Quality Gate (optional)

If the Inspector General (wsp-gate) is available, commission it for production-readiness checks:

Delegate to wsp-gate (read `skills/wsp-gate/SKILL.md`). wsp-gate:
1. Reads gate config from `.wasup/wasup.toml`
2. Runs configured checks (audit, secrets, test_rate, memory_patterns, deprecated_api, no_use)
3. Writes gate report and verdict

Output: `.wasup/gates/vx.y.z.md`

**If FAILED** — fix fail_on items, re-run Governor Audit + Gate
**If PASSED** — proceed to Ratify

## Phase 5: Ratify

### 5.1 Governor Signs

Governor confirms:
- All acceptance criteria met
- Cleaner has passed
- No policy violations

Mark proposal: status → `Ratified`

### 5.2 Mayor Declares

Mayor announces the town update:

```bash
echo "Proposal $(ls .wasup/town/proposals/*.md | tail -1) ratified on $(date +%Y-%m-%d)" >> .wasup/town/chronicle.md
```

## Phase 6: Report

### 6.1 Generate Changelog (optional)

If the Town Chronicler (relote) is available, commission it for release notes:

Delegate to relote (read `skills/relote/SKILL.md`). relote:
1. Discovers the latest tag from git
2. Aggregates changes from git history
3. Generates Keep-A-Changelog formatted notes

Output: `.wasup/changelogs/vx.y.z.md`

### 6.2 Publish Town Chronicle

Write `.wasup/town/chronicle.md`:
```markdown
# Town Chronicle

## Session [Date]

### Ratified Proposals
- [Proposal 001]: [Title] — Ratified

### Services Commissioned
- [ ] wsp-opt (Planning Commission)
- [ ] wsp-sync (Records Department)
- [ ] wsp-gate (Inspector General)
- [ ] relote (Town Chronicler)

### Town Health
- **Population**: Mayor, Architect, Developer, Cleaner, Governor
- **Backlog**: N pending proposals
- **Constitution**: Up to date

### Notes
[Mayor's remarks]
```

### 6.3 Present to User

> "Town session complete. N proposals ratified. The chronicle is at `.wasup/town/chronicle.md`. Services commissioned: [list]. Town is healthy. Awaiting next session."

## Important Notes

- **Mayor starts and ends every session** — never skip Convene or Report
- **Proposals flow in order** — Draft → Proposed → Planned → Built → Cleaned → Audited → Ratified
- **Governor can reject at any review stage** — sends back with reasons
- **Constitution is law** — citizens must not act outside it
- **Each citizen runs as a focused sub-agent** — do not let one citizen do another's job
- **Chronicle is append-only** — never overwrite, only append new entries
- **External services are optional** — town functions without them, services add rigor
- **Services write outside `.wasup/town/`** — wsp-opt → `.wasup/todos/`, wsp-sync → `.wasup/sync/`, wsp-gate → `.wasup/gates/`, relote → `.wasup/changelogs/`
- **Services respect the constitution** — all external work must comply with town laws
