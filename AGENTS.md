# AGENTS.md — AI Agent Reference

> A concise reference for AI agents (Claude Code, Cursor, Codebuff, etc.) working on this project.

---

## Project Philosophy

**Build less, but useful.** Every skill solves one real problem well. No frameworks, no boilerplate, no over-engineering.

This repo is a self-contained collection of AI agent skills — markdown files that teach agents how to perform specific development tasks (planning, syncing docs, security auditing, generating release notes).

---

## Skill System

### Loading a Skill

Skills are loaded by name. Each skill lives under `skills/<name>/` with a `SKILL.md` as the entrypoint.

```json
{
  "name": "<skill-name>"
}
```

### Pipeline Order

`wsp-opt` (Plan) → `wsp-sync` (Sync Docs) → `wsp-gate` (Quality Gate) → `relote` (Release Notes)

### Trigger Keywords

Agents match user requests against these keywords to activate the right skill. This is the **authoritative** table.

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `wsp-opt` | "let's build", "task management", "wasup" | Feature planning, MoSCoW prioritization, branching |
| `wsp-sync` | "sync up", "update docs", "tidy up docs" | Scan & update stale `.md` docs |
| `wsp-gate` | "run gate", "production check", "security audit", "is it ready to ship" | Security audit, secrets check, dead code |
| `relote` | "changelog", "release notes", "relote" | Keep-A-Changelog formatted release notes |
| `wsp-town` | "town hall", "wsp-town", "citizens assemble" | Multi-agent governance simulation (optional) |

### Governance Layer (Optional)

`wsp-town` wraps the pipeline in a town simulation with sub-agents: Mayor → Architect → Developer → Cleaner → Governor → Ratify.

---

## GitButler Mandate

> **All Git write operations must use `but` (GitButler CLI).**
> Never use raw `git` for: `add`, `commit`, `push`, `checkout`, `merge`, `rebase`, `stash`, `cherry-pick`.

### Core Philosophy

**Work first, organize later.** GitButler uses **virtual branches** in a workspace model:

1. Make changes — they're auto-assigned to a virtual branch
2. Name the branch later once work has a clear purpose
3. Multiple branches can be applied simultaneously in the working directory

### Key Commands

| Operation | Command |
|-----------|---------|
| View state | `but status -fv` |
| Create branch | `but branch new feat/v<ver>-<desc>` |
| Rename branch | `but branch rename <id> <name>` |
| Commit | `but commit <branch-id> -m "type(scope): desc"` |
| Auto-amend | `but absorb` |
| Merge | `but merge <branch-id>` |
| Push | `but push <branch-id>` |
| Pull | `but pull` |
| Resolve conflicts | `but resolve <commit-id>` → edit → `but resolve finish` |
| Undo | `but undo` |
| View history | `but oplog` |
| Create PR | `but pr create` |
| Create tag | `git tag -a v<ver> -m "...` (but has no tag — read-only exception) |

### Commit Convention

[Conventional Commits](https://www.conventionalcommits.org/) strictly:

```
<type>(<scope>): <description>

<body>
```

Allowed types: `feat`, `fix`, `docs`, `refactor`, `perf`, `style`, `test`, `chore`, `build`, `ci`.

### Version Bump Rules

| Scope | Bump | Example |
|-------|------|---------|
| Major feature release | major (reset minor, patch) | `v1.0.0` → `v2.0.0` |
| Feature addition (backward compatible) | minor (reset patch) | `v0.1.0` → `v0.2.0` |
| Bug fix (backward compatible) | patch | `v0.1.0` → `v0.1.1` |

Version tracked in `.wasup/wasup.toml`.

---

## Skill Structure Convention

Each skill lives at `skills/<name>/` with `SKILL.md` as the entrypoint. Sub-agents go in `agents/`, reference docs in `references/`.

### SKILL.md Frontmatter

```yaml
---
name: <skill-name>
description: One-line description + trigger keywords.
metadata:
  author: EdwardJoke
  version: <semver>
---
```

### Key Rules

- **Self-contained** — all instructions in one directory
- **Single responsibility** — one skill, one job
- **Delegate, don't duplicate** — call other skills instead of reimplementing
- **`.wasup/`** — all state and output files go here

---

## Convention Summary for Agents

1. **Read context first** — understand existing code before editing
2. **Use `but` for Git** — never raw `git` write commands
3. **Check `.wasup/wasup.toml`** for current version and config
4. **Follow the pipeline** — `wsp-opt` → `wsp-sync` → `wsp-gate` → `relote`
5. **Commit messages** — Conventional Commits format
6. **One commit per logical change** — use `but absorb` for small fix-ups
7. **Resolve conflicts** with `but resolve`, never `git merge`/`git rebase`
8. **Self-contained skills** — don't assume external runtimes or frameworks

---

*See [SPEC.md](SPEC.md) for the full project specification.*
