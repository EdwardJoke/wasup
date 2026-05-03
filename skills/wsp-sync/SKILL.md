---
name: wsp-sync
description: >
  Sync project documentation with current codebase state by scanning and updating outdated .md files.
  Use this skill whenever the user says "sync up", "sync my project status", "update docs",
  "tidy up docs", "update memory", "clean up docs", or wants to update/sync the current
  project's status. Also trigger when user mentions stale docs, conflicting memories,
  documentation drift, or wants a clean handoff to teammates or other agents.
  Works across Claude Code, OpenAI Codex, OpenCode, and OpenClaw.
---

# wsp-sync - Project Documentation Sync

Automatically scan `.md` files, detect outdated information, and update documents to match the current codebase state. Generates a versioned sync report.

## Overview

The sync workflow has three phases:
1. **Scan** - Deep scan all `.md` files in the project
2. **Update** - Refresh outdated content (docs/ first, then root config files)
3. **Report** - Output a versioned sync report

## Phase 1: Scan

### 1.1 Discover all `.md` files

```bash
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" -not -path "./target/*" -not -path "./build/*" 2>/dev/null
```

This finds all markdown files worth scanning. Exclude build artifacts and dependencies.

### 1.2 Read project context

Read these files to understand current state:
- `git status` - What's changed
- `git log --oneline -20` - Recent history
- `.wasup/todos/*.md` - Current task state
- `.wasup/PURPOSE.md` - Project intent (if exists)

Understanding what changed helps identify which docs are stale.

### 1.3 Identify outdated documents

For each `.md` file found, check:
- Does it reference files/functions/classes that no longer exist?
- Are version numbers/tags in the doc matching `git describe --tags` or package files?
- Do code examples still work with current APIs?
- Are architectural descriptions still accurate?
- Do links to internal files still resolve?

Focus on `.md` files only — never modify other file extensions.

## Phase 2: Update

### 2.1 Update `docs/` directory first

```bash
ls docs/*.md 2>/dev/null
```

Read and update each file in `docs/`:
- Fix broken references
- Update version numbers
- Correct API descriptions
- Remove references to deleted features
- Update architecture diagrams (in text form)

Why docs/ first: These are the primary documentation that users and new agents read. They should reflect reality.

### 2.2 Update root AI config files

After `docs/` is synced, update these root-level files:
- `CLAUDE.md` - Claude Code instructions
- `AGENTS.md` - Agent instructions
- `GEMINI.md` - Gemini instructions

Check that these files:
- List actually available tools/skills
- Reference correct file paths
- Describe current architecture
- Have accurate build/test commands
- Reflect actual project structure

Why last: These files guide AI behavior. They must match the post-sync state of docs/.

### 2.3 Update rules

Only modify `.md` files. Skip:
- `.json`, `.yaml`, `.toml` config files
- Source code files
- Build artifacts
- Binary files

The goal is documentation consistency, not config management.

## Phase 3: Report

### 3.1 Create sync report directory

```bash
mkdir -p .wasup/sync
```

### 3.2 Determine version

Read the latest version from `.wasup/tags/`, `.wasup/todos/` or Git:
- If no tags exist, start with `v0.1.0`
- Read existing `.wasup/sync/` to avoid version conflicts

### 3.3 Write sync report

Create `.wasup/sync/vx.y.z.md`:

```markdown
# Sync Report vx.y.z
**Date**: [YYYY-MM-DD]

## Files Updated

### docs/
- [x] `docs/ARCHITECTURE.md` - Updated API section to match v2 endpoints
- [x] `docs/SETUP.md` - Fixed broken install commands

### Root Config
- [x] `CLAUDE.md` - Removed deprecated skill references
- [x] `AGENTS.md` - Updated available tools list

## Changes Summary
- Fixed 3 broken internal links
- Updated 2 version references from v1.2.3 to v1.3.0
- Removed references to deprecated `old_feature` module
- Added new `auth` module to architecture docs

## Files Skipped
- `README.md` - User requested no changes
- `examples/old.md` - Archived, intentionally stale
```

Be specific about what changed and why. This creates an audit trail.

## Completion

Present to user:
> "Sync vx.y.z complete. Updated N files (docs/ first, then root config). Full report at `.wasup/sync/vx.y.z.md`. Key changes: [brief summary]"

Stop here. Wait for user direction.

## Important Notes

- **Only `.md` files** - Never modify source code, configs, or other extensions
- **docs/ first** - Update documentation before AI config files
- **Preserve intent** - Fix factual errors, not writing style
- **Version reports** - Each sync gets a unique versioned report in `.wasup/sync/`
- **No force updates** - If user says "don't update X", skip it and note in report
