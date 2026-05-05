---
name: relote
description: >
  Generate a Keep-A-Changelog formatted changelog for the latest git tag.
  Deeply integrates wsp-opt and wsp-sync outputs, aggregates git history,
  and produces a structured release notes file. Use this skill whenever the user
  asks to "generate changelog", "release notes", "what changed in vX.Y.Z",
  "summarize this release", or mentions "relote", "changelog", "release notes".
  Also trigger when the user finishes a release and wants a formal changelog,
  or needs to document what changed between tags in Keep-A-Changelog format.
---

# relote - Release Notes Generator

Generate a Keep-A-Changelog formatted changelog by aggregating wsp-opt release notes, wsp-sync sync reports, and git history for the latest tag.

## Overview

The relote workflow has three phases:
1. **Discover** - Find the latest tag and gather context from wsp-opt and wsp-sync
2. **Aggregate** - Collect and categorize changes from multiple sources
3. **Generate** - Write a Keep-A-Changelog formatted changelog to `.wasup/changelogs/vx.y.z.md`

## Prerequisite: wasup Structure

Ensure these directories exist (create if missing):
```bash
mkdir -p .wasup/changelogs
mkdir -p .wasup/tags
mkdir -p .wasup/sync
```

## Phase 1: Discover

### 1.1 Find the Latest Tag

```bash
# Get latest tag
git describe --tags --abbrev=0 2>/dev/null || echo "No tags found"
```

If no tags exist, ask the user: "No git tags found. What version should the changelog be for? (e.g., v1.0.0)"

### 1.2 Get Previous Tag (for diff)

```bash
# Get previous tag for commit range
git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo "Initial release"
```

### 1.3 Read wsp-opt Output

Check for release notes from wsp-opt Phase 5:
```bash
ls .wasup/tags/*.md 2>/dev/null | sort -V | tail -1
```

Read the most recent tag file (e.g., `.wasup/tags/v0.1.0.md`). This contains:
- What's New
- Completed Tasks (with Must/Should have markers)
- Bug Fixes
- PRs
- Known Issues

### 1.4 Read wsp-sync Output

Check for sync reports:
```bash
ls .wasup/sync/*.md 2>/dev/null | sort -V | tail -1
```

Read the most recent sync report (e.g., `.wasup/sync/v0.1.0.md`). This contains:
- Files Updated
- Changes Summary
- What was synced

### 1.5 Get Git Commit History

```bash
# Get commits between tags (or all commits if first release)
if [ -n "$PREV_TAG" ]; then
  git log --oneline --no-merges $PREV_TAG..HEAD
else
  git log --oneline --no-merges
fi
```

Also get detailed commit info:
```bash
git log --pretty=format:"%h|%s|%b" --no-merges ${PREV_TAG}..HEAD 2>/dev/null
```

## Phase 2: Aggregate

### 2.1 Parse wsp-opt Release Notes

Extract from `.wasup/tags/vx.y.z.md`:
- **What's New** → `## Added`
- **Completed Tasks** → Categorize by type (feat, fix, chore)
- **Bug Fixed** → `## Fixed`
- **PRs** → Reference in relevant sections

### 2.2 Parse wsp-sync Report

Extract from `.wasup/sync/vx.y.z.md`:
- **Files Updated** → `## Changed` (documentation updates)
- **Changes Summary** → Distribute to appropriate sections

### 2.3 Categorize Git Commits

Map conventional commit types to Keep-A-Changelog sections:
- `feat:` → `## Added`
- `fix:` → `## Fixed`
- `perf:` → `## Changed` (performance improvements)
- `refactor:` → `## Changed`
- `docs:` → `## Changed` (documentation)
- `style:` → Skip (cosmetic changes)
- `test:` → Skip (test-only changes, unless user wants them)
- `chore:` → `## Chores` (optional section)
- `build:`, `ci:` → Skip (infrastructure)

### 2.4 Merge and Deduplicate

Combine information from all three sources:
- wsp-opt gives high-level "what" (features, tasks)
- wsp-sync gives documentation changes
- git log gives commit-level details

Remove duplicates (same change mentioned in multiple sources).

## Phase 3: Generate Changelog

### 3.1 Create Changelog File

Determine version from tag:
```bash
VERSION=$(git describe --tags --abbrev=0)
mkdir -p .wasup/changelogs
```

Write to `.wasup/changelogs/${VERSION}.md`

### 3.2 Follow Keep-A-Changelog Format

Use this exact template:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [vx.y.z] - YYYY-MM-DD

### Added
- Feature description (from wsp-opt What's New)
- Another feature (#PR-number)

### Changed
- Documentation updated (from wsp-sync)
- Performance improvement (from git log)

### Fixed
- Bug description (from wsp-opt Bug Fixed)
- Another fix (#PR-number)

### Chores (optional)
- Build system updates
- Dependency updates
```

### 3.3 Populate Sections

**Added section** - New features:
- Pull from wsp-opt "What's New"
- Pull from git log `feat:` commits
- Include PR references if available: `[#123](https://github.com/org/repo/pull/123)`

**Changed section** - Changes to existing functionality:
- Pull from wsp-sync "Files Updated"
- Pull from git log `refactor:`, `perf:` commits
- Include documentation updates

**Fixed section** - Bug fixes:
- Pull from wsp-opt "Bug Fixed"
- Pull from git log `fix:` commits

**Removed section** (if applicable):
- Features removed in this version

**Security section** (if applicable):
- Security fixes from git log or wsp-opt

### 3.4 Add Metadata

At the top of the file, add:
```markdown
<!-- 
  Generated by relote skill
  Sources: wsp-opt, wsp-sync, git log
  Generated: YYYY-MM-DD HH:MM:SS
-->
```

### 3.5 Compare with Previous Changelog

If a previous changelog exists in `.wasup/changelogs/`, read it to:
- Ensure no sections are missing
- Check that version ordering is correct
- Verify format consistency

## Output

The final changelog is saved to:
```
.wasup/changelogs/vx.y.z.md
```

Present to user:
> "Changelog generated at `.wasup/changelogs/vx.y.z.md`. I've aggregated data from wsp-opt release notes, wsp-sync reports, and git history. Here's what's included: [brief summary of sections]"

## Important Notes

- **Keep-A-Changelog format** - Follow the spec exactly (Added, Changed, Fixed, etc.)
- **Semantic versioning** - Version numbers should follow semver (vx.y.z)
- **Deduplication** - Same change may appear in wsp-opt, wsp-sync, and git log - include only once
- **PR links** - Include PR references when available from wsp-opt or git log
- **Date format** - Use ISO 8601 (YYYY-MM-DD)
- **No empty sections** - Only include sections that have content

## Example Output

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.0] - 2026-05-05

### Added
- User authentication with JWT tokens (M1 from wsp-opt)
- Password reset functionality (S1 from wsp-opt)
- New `/api/auth/reset` endpoint (#12)

### Changed
- Updated API documentation in `docs/API.md` (from wsp-sync v0.1.0)
- Refactored auth middleware for better performance

### Fixed
- Login page now handles expired tokens correctly (Bug1 from wsp-opt)
- Password reset email delivery issue (#15)
```
