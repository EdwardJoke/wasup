---
name: wsp-opt
description: Structured dev workflow with MoSCoW prioritization, git branching, and atomic commits. The trigger is let's build, task management, wasup.
metadata:
  author: EdwardJoke
  version: 26.1.0
---

# wasup - Task Management Skill

A structured development workflow that takes an idea from concept to released feature using MoSCoW prioritization, git branching, and atomic commits.

## Overview

The wasup workflow has six phases:
1. **Purpose** - Capture what to build
2. **Plan** - Define tasks using MoSCoW method
3. **Execute** - Build with atomic commits on feature branches
4. **Review** - Review and approve changes before merging to master
5. **Gate & Changelog** - Quality gate check then generate release notes
6. **Release** - Tag and merge to master

## Prerequisites: wasup config file

Generate `.wasup/wasup.toml` in the root directory with template: 
```markdown
[repo]
name = [the name of root folder]
current_version = "vx.y.z"
next_version = "vx.y.z"

[repo.branches]
dev = "dev"
main = "master"
```

## Phase 1: Purpose

Start by capturing the project idea in `.wasup/PURPOSE.md`.

```bash
mkdir -p .wasup
```

Create `.wasup/PURPOSE.md`. Ask user each question, fill as you go:
- **What** — one sentence describing what to build
- **Why** — what problem it solves
- **Success Criteria** — 2-3 items that define done

## Phase 2: Plan with MoSCoW

Ask the user: "The scope of updates in the current version is: Function (Main) / Patch (Major) / Bug (Minor) / Type your own Version Number ?"

Create a versioned todo file `.wasup/todos/vx.y.z.md` using strict semver format only (`vX.Y.Z`, for example `v1.0.0`, `v0.1.0`, `v0.0.1`).

Version bump rules:
- **Function (Main)**: bump major (`x`) and reset minor/patch to zero.
- **Patch (Major)**: bump minor (`y`) and reset patch to zero.
- **Bug (Minor)**: bump patch (`z`) only.

Then update the `current_version` inside `.wasup/wasup.toml`.

### MoSCoW Method

Explain to user:

> "MoSCoW: **Must** (critical — project fails without), **Should** (important, not blocking), **Could** (nice to have), **Won't** (explicitly out of scope this version)."

Ask the user to list tasks they can think of. As they provide tasks, help categorize them into MoSCoW buckets. Then present the organized list:

```markdown
# Todo
> Target Version: vx.y.z | Mode: Function/Patch/Bug

## Must have
- [ ] M1: [Task description] - [Brief reason why critical]
- [ ] M2: [Task description]

## Should have
- [ ] S1: [Task description]

## Could have
- [ ] C1: [Task description]

## Won't have (this version/defer to vx.y.z)
- [ ] W1: [Task description]
```

After presenting, ask: "Do these priorities look right? Would you like to move any tasks between categories, or add/remove anything?"

Wait for their response. If they want changes, update the file and re-confirm. Repeat until they're satisfied.

Finally, add priority ordering within each category. Mark the very first task with `**NEXT**` label:

```markdown
- [ ] **NEXT** M1: [First task to execute]
```

## Phase 3: Execute

### Start Feature Branch

Read `.wasup/todos/vx.y.z.md` to identify the NEXT task. Create a feature branch:

```bash
git checkout -b feat/v0.1.0-[short-description]
```

Example: `git checkout -b feat/v0.1.0-auth`

### Build the Task

Focus on the current NEXT task only. Break it into small, completable steps. Work through each step:

1. Implement the step
2. Test/build to check for errors
3. Fix any issues before moving to next step
4. When step is complete and working, make an atomic commit:

```bash
git add [specific files]
git commit -m "type(scope): description

Detailed explanation if needed"
```

Commit message guidelines:
- Follow [Conventional Commits](https://www.conventionalcommits.org/) spec exactly: `<type>(<scope>): <description>`
- Subject ≤50 chars. Body explains WHY (diff shows what).
- Each commit = single logical change that could stand alone.

After committing, update the todo file:
- Mark the completed task: `- [x] M1: ...`
- Find the next task, mark it `**NEXT**`

### Continue to Next Task

Repeat the build-commit cycle:
1. Read todo to find NEXT task
2. If on a new category (Must→Should), ask: "Must-haves complete. Ready to start should-haves?"
3. Build the task with atomic commits
4. Update todo

Continue until all Must-have and Should-have tasks are done, then ask for Could-have (if accept then repeat the cycle upon).

## Phase 4: Review

Run the reviewer by reading `agents/reviewer.md` and following its instructions to check the project against the todo list.

Delegate review to sub-agent if platform supports it. Otherwise scan inline for bugs, missing impl, quality issues. Compare against todos.

After the review finishes, re-run it with fresh context. Repeat until every todo item is verified complete.

### Config Gate

Before proceeding, ensure `.wasup/wasup.toml` has a `[gate]` section:

```toml
[gate]
enabled = true
checks = ["audit", "secrets", "test_rate", "memory_patterns", "deprecated_api", "no_use"]
fail_on = ["audit", "secrets", "deprecated_api"]
thresholds.test_pass_rate = 100
```

Add one if missing. Then create required directories:

```bash
mkdir -p .wasup/gates
```

## Phase 5: Gate & Changelog

### Quality Gate

Run `/wsp-gate`. Output: `.wasup/gates/vx.y.z.md`.
- **FAILED** — fix fail_on items, re-run Review + Gate
- **PASSED** — proceed to changelog

### Release Notes

Run `/relote`. Output: `.wasup/changelogs/vx.y.z.md`.

```bash
git add .wasup/changelogs/vx.y.z.md && git commit -m "docs(changelog): add vx.y.z release notes"
```

## Phase 6: Release

### Tag and Merge

Ask user: "Which branch should the current branch be merged into, dev or master?"

Present release checklist, require explicit confirmation:

```markdown
Release plan: tag=vx.y.z, source=feat/vx.y.z-<desc>, target=master|dev
Commands: git tag, git checkout target, git merge --no-ff, git push, git push --tags
```

If no explicit confirm, stop.

```bash
git tag -a v0.1.0 -m "Release v0.1.0" && git checkout master && git merge --no-ff feat/v0.1.0-feature -m "Merge feat/v0.1.0-feature into master" && git push origin master && git push origin --tags
```

Present: "Release vx.y.z ready. Tagged, pushed, merged. What's next?"

Stop here. Wait for user direction.
