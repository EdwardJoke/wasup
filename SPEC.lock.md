# Wasup — Project Specification

> **Philosophy**: *Build less, but useful.*
> Every skill in this repo solves one real problem well. No frameworks, no boilerplate, no over-engineering.

---

## 1. Project Goal

Wasup is a **self-contained collection of AI agent skills** for structured development workflows. Each skill is a markdown file (or a directory of markdown files) that an AI agent reads to learn *how* to perform a specific task — from planning a feature to generating release notes.

**What this repo is:**
- A library of agent instructions (`.md` skill files)
- A pipeline: `wsp-opt → wsp-sync → wsp-gate → relote`
- A governance layer (`wsp-town`) that wraps the pipeline in a town simulation metaphor

**What this repo is not:**
- Not a runtime, framework, or library
- Not a language-specific tool (works with any stack)
- Not a SaaS platform

**Target audience:**
- Developers who use AI coding agents (Claude Code, Cursor, Windsurf, etc.)
- AI agents themselves who need structured instructions to complete tasks
- Contributors who want to improve or add new skills

---

## 2. Skill Structure Convention

See [AGENTS.md](AGENTS.md#skill-structure-convention) for full details.

**Quick reference:**
```
skills/<name>/
  SKILL.md       — Main skill instructions (required)
  agents/        — Sub-agent definitions
    <agent>.md
```

Every `SKILL.md` starts with YAML frontmatter containing `name`, `description` (with trigger keywords), and `metadata.author` + `metadata.version`.

---

## 3. Skill Pipeline

```
wsp-opt ──► wsp-sync ──► wsp-gate ──► relote
   │            │             │          │
   ▼            ▼             ▼          ▼
  Plan      Sync Docs    Quality Gate   Release Notes
```

### 3.1 Pipeline Flow

| Phase | Skill | Output | Purpose |
|-------|-------|--------|---------|
| Plan | `wsp-opt` | `.wasup/todos/vx.y.z.md` | MoSCoW prioritization, GitButler branching, atomic commits |
| Sync | `wsp-sync` | `.wasup/sync/vx.y.z.md` | Scan & update stale `.md` docs |
| Gate | `wsp-gate` | `.wasup/gates/vx.y.z.md` | Security audit, secrets check, test pass rate, deprecated APIs, unused code |
| Release | `relote` | `.wasup/changelogs/vx.y.z.md` | Keep-A-Changelog formatted release notes |

### 3.2 Skill Dependencies

| Skill | Delegates to | Called by |
|-------|-------------|-----------|
| `wsp-opt` | `wsp-gate` (quality gate), `relote` (changelog) | `wsp-town` (Planning Commission) |
| `wsp-sync` | — | `wsp-opt` (doc sync after builds), `wsp-town` (Records Department) |
| `wsp-gate` | — | `wsp-opt` (pre-release check), `wsp-town` (Inspector General) |
| `relote` | — | `wsp-opt` (release notes), `wsp-town` (Town Chronicler) |

### 3.3 Governance Layer

`wsp-town` is an **optional** multi-agent simulation that wraps the pipeline in a town governance metaphor. It is a **public preview** feature.

```
Mayor ──► Architect ──► Developer ──► Cleaner ──► Governor ──► Ratify
  │           │             │             │            │
  │     (Plan)         (Build)       (Polish)     (Audit)
  │           │             │             │            │
  └──── wsp-opt ── wsp-sync ── wsp-gate ── relote ─────┘
```

---

## 4. GitButler Workspace & Branch Management

See [AGENTS.md](AGENTS.md#gitbutler-mandate) for the full GitButler mandate, virtual branch strategy, commit convention, and version bump rules.

### 4.1 Git-to-But Command Mapping

| Operation | Git (❌ forbidden) | GitButler (✅ use this) |
|-----------|-------------------|------------------------|
| View state | `git status` | `but status -fv` |
| Create named branch | `git checkout -b <name>` | `but branch new <name>` |
| Rename branch | — | `but branch rename <id> <name>` |
| Apply/unapply branch | `git checkout` / `git stash` | `but apply` / `but unapply` |
| Commit | `git commit -m "..."` | `but commit <branch-id> -m "..."` |
| Auto-amend | `git commit --amend` | `but absorb` |
| Merge | `git merge <branch>` | `but merge <branch-id>` |
| Resolve conflicts | `git merge` + manual fix | `but resolve <commit-id>` → edit → `but resolve finish` |
| Pull | `git pull` | `but pull` |
| Push | `git push` | `but push <branch-id>` |
| Create PR | `gh pr create` | `but pr create` |
| Cherry-pick | `git cherry-pick <hash>` | `but pick <commit-id>` |
| Squash | `git rebase -i` | `but squash` |
| Undo | `git reset HEAD~1` | `but undo` |
| View history | `git reflog` | `but oplog` |
| View diff | `git diff` | `but diff` |
| Delete branch | `git branch -d` | `but branch delete <id>` |
| Stack branches | — | `but move <child> <parent>` |

> Read-only commands safe to use: `git tag`, `git log`, `git diff`, `git show`, `git describe`.

### 4.2 Merge & Release Strategy

1. After all tasks complete → **Review** → **Gate** → **Changelog**
2. Present release checklist, get explicit confirmation
3. Merge, tag, push:

```bash
but status -fv
but merge <feature-branch-id>
git tag -a v<version> -m "Release v<version>"
but push <target-branch-id>
git push origin --tags
```

**Conflict resolution:** `but resolve <commit-id>` → edit → `but resolve finish`. Never use `git merge`, `git rebase`, or `git add`.

---

## 5. Project State Files

All wasup-generated files live under `.wasup/`:

```
.wasup/
├── wasup.toml          — Project config (version, branches, gate)
├── PURPOSE.md          — Project purpose statement
├── todos/              — MoSCoW task lists
│   └── v<version>.md
├── gates/              — Quality gate reports
│   └── v<version>.md
├── changelogs/         — Release notes
│   └── v<version>.md
├── sync/               — Documentation sync reports
│   └── v<version>.md
├── tags/               — Release tag notes
│   └── v<version>.md
└── town/               — Governance simulation files
    ├── constitution.md
    ├── proposals/
    └── chronicle.md
```

---

## 6. AI Agent Guidelines

See [AGENTS.md](AGENTS.md#convention-summary-for-agents).

For contributors:
- Each skill is a **single responsibility**: one skill, one job
- Skills delegate but do not duplicate
- Preserve the `SKILL.md` format: frontmatter + markdown body
- Add trigger keywords to the description field
- Use `.wasup/` for all state and output files

### Skill Directory Reference

| Directory | Skill | Agent files |
|-----------|-------|-------------|
| `skills/wsp-opt/` | Development workflow | `agents/reviewer.md` |
| `skills/wsp-sync/` | Documentation sync | — |
| `skills/wsp-gate/` | Quality gate | — |
| `skills/relote/` | Release notes | — |
| `skills/wsp-town/` | Governance simulation | `agents/mayor.md`, `agents/architect.md`, `agents/developer.md`, `agents/cleaner.md`, `agents/governor.md` |

---

## 7. License

Apache 2.0 — see [LICENSE.md](LICENSE.md).

---

*This specification is a living document. Update it when adding new skills or changing conventions.*
