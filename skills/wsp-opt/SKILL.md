---
name: wsp-opt
description: >
  Task management skill for structured development workflow with git integration.
  Use this skill whenever the user wants to start a new project, feature, or development task.
  Triggers on phrases like "let's build", "start working on", "create a new feature",
  "task management", "MoSCoW", "todo list", or when the user wants to organize and execute
  development work with proper git branching, atomic commits, and release management.
  Also trigger when user mentions wasup, purpose files, feature branches, or structured workflows.
---

# wasup - Task Management Skill

A structured development workflow that takes an idea from concept to released feature using MoSCoW prioritization, git branching, and atomic commits.

## Overview

The wasup workflow has three phases:
1. **Purpose** - Capture what to build
2. **Plan** - Define tasks using MoSCoW method
3. **Execute** - Build with atomic commits on feature branches
4. **Release** - Tag and merge to master

## Prerequisites: wasup config file

Gennerate `.wasup/wasup.toml` in the root directory with template: 
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

Create `.wasup/PURPOSE.md` with this structure:

```markdown
# Project Purpose

## What
[Describe what you want to build - one clear sentence]

## Why
[Why build this? What problem does it solve?]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

Ask the user: "What's the one core function or feature you want this project to have? Describe it in one sentence."

Save their answer in the What section. Then ask: "Why does this matter? What problem are you solving?" Save in Why section. Finally, ask: "How will you know it's done? List 2-3 success criteria."

## Phase 2: Plan with MoSCoW

Ask the user: "The scope of updates in the current version is: Function (Main) / Patch (Major) / Bug (Minor) / Type your own Version Number ?"

Create a versioned todo file `.wasup/todos/vx.y.z.md` (start with `v1.0.0`, `v0.1.0` or `v.0.0.1`, based on the update scope selected by the user: Function to add 1 on `x`, Patch to add 1 on `y` and Bug to add 1 on `z`).

Then update the `current_version` inside `.wasup/wasup.toml`.

### MoSCoW Method

Explain to the user:

> "We'll organize tasks using MoSCoW prioritization:
> - **Must have** - Critical, without these the project fails
> - **Should have** - Important but not critical for initial release
> - **Could have** - Nice to have, consider for future
> - **Won't have** - Explicitly out of scope for this version"

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
- Use conventional commits: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- Keep the subject line under 50 chars
- The body explains WHY, not WHAT (the diff shows what)
- Each commit should be a single logical change that could stand alone
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) standard **exactly**:
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

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

## Phase 4: Release

### Create Release Notes

Create `.wasup/tags/v0.1.0.md`:

```markdown
# Release v0.1.0

## What's New
- [Feature/benefit 1]
- [Feature/benefit 2]

## Completed Tasks
- [x] M1: ...
- [x] M2: ...

## Bug Fixed
- [x] Bug1: ...

## PRs
- [#1]: Merge PR [#1] from [author]

## Known Issues
- [Any remaining could-haves or limitations]

## Upgrade Notes
[Any breaking changes or migration steps]
```

### Tag and Merge

Ask user: "Which branch should the current branch be merged into, dev or master?"

```bash
git tag -a v0.1.0 -m "Release v0.1.0"
git checkout master # or dev
git merge --no-ff feat/v0.1.0-feature -m "Merge feat/v0.1.0-feature into master" # or dev
```

Present to user: "Release vx.y.z is ready. I've tagged and merged to master/dev. The feature branch `feat/vx.y.z-[name]` is now merged. What's next?"

Stop here. Wait for user direction.
