
<div align="center">

![The Brand picture of Wasup](/assets/Wasup.png)

# Wasup Skill

![badge](https://img.shields.io/github/downloads/EdwardJoke/wasup/total?style=flat&color=174084) ![badge](https://img.shields.io/github/license/EdwardJoke/wasup?style=flat) ![badge](https://img.shields.io/github/stars/EdwardJoke/wasup?style=flat) ![badge](https://img.shields.io/github/last-commit/EdwardJoke/wasup?style=flat)<br/>
![GitHub Open Issues](https://img.shields.io/github/issues/EdwardJoke/wasup?style=flat) ![GitHub Contributors](https://img.shields.io/github/contributors/EdwardJoke/wasup?style=flat)

A collection of AI agent skills for structured development workflow, quality gating, documentation sync, release notes, and town governance simulation. Built to help developers and AI agents get out of task management troubles.

---
</div>

## Features

### Skill Pipeline

```
wsp-opt → wsp-sync → wsp-gate → relote
```

- **wsp-opt** — Structured development workflow with `MoSCoW` (Must/Should/Could/Won't Have) prioritization, git branching, and atomic commits
- **wsp-sync** — Automated documentation sync that scans and updates outdated `.md` files to match the codebase
- **wsp-gate** — Pre-release security & production-readiness gate. Runs dep audits, secrets scan, test health, memory patterns, and unused code checks before release
- **relote** — Keep-A-Changelog release notes generator, aggregating data from git history and other skills

### Governance Layer

- **wsp-town** — Multi-agent town governance simulation. The Mayor orchestrates citizens (Architect, Developer, Cleaner, Governor) through proposals, builds, and reviews. Can optionally commission the four pipeline skills as external municipal services. `🔬 Public Preview`

### Skill Relationships

| Skill | Delegates to | Called by |
|-------|-------------|-----------|
| **wsp-opt** | wsp-gate (quality gate), relote (changelog) | wsp-town (Planning Commission) |
| **wsp-sync** | — | wsp-opt (doc sync after builds), wsp-town (Records Department) |
| **wsp-gate** | — | wsp-opt (pre-release check), wsp-town (Inspector General) |
| **relote** | — | wsp-opt (release notes), wsp-town (Town Chronicler) |

Each skill is **self-contained** and can be used independently. The pipeline flows left to right for a complete release cycle, while wsp-town wraps them as a governance metaphor.

---

## Prerequisites

This project requires **GitButler**, a Git workspace manager that uses virtual branches and the `but` CLI.

> **Why GitButler?** Wasup's skills (`wsp-opt`, `wsp-sync`, etc.) orchestrate Git operations exclusively through `but` — never raw `git` — for safer, branchless workflows.

### Install GitButler CLI (`but`)

#### macOS & Linux

Run the official installer script:

```bash
curl -fsSL https://gitbutler.com/install.sh | sh
```

This installs the `but` command globally and sets up the GitButler CLI.

#### Via GitButler Desktop (All Platforms)

1. Download and install the [GitButler desktop app](https://gitbutler.com/download) for your platform
2. Open the app → **General Settings**
3. Click **"Install CLI"** — this creates a global symlink so `but` is available in your terminal

#### Windows

Install the [GitButler desktop app](https://gitbutler.com/download) and use the **"Install CLI"** button in Settings. Windows CLI support is evolving alongside the desktop client.

#### Verify Installation

```bash
but --version
```

You should see a version number (e.g., `but 0.x.y`).

---

## Quick Start

To get started with Wasup, follow these steps:

### Install Wasup Skills

#### Use skills manager from Vercel (Recommended)

```bash
npx skills add EdwardJoke/wasup
# Or
pnpx skills add EdwardJoke/wasup
# Or
bunx skills add EdwardJoke/wasup
# Or
aubx skills add EdwardJoke/wasup
```

#### Download the `.zip` file directly (Not recommended)
We don't recommend this as it loses the automated update feature.

### Usage (AI Agent Prompts)

These are **skill names** that auto-trigger when you say the keywords to your AI agent:

1. Say **"let's build [feature]"** or **"start a new project"** to activate `wsp-opt`
2. Say **"sync up"** or **"update docs"** to activate `wsp-sync`
3. Say **"run gate"** or **"production check"** to activate `wsp-gate`
4. Say **"generate changelog"** or **"relote"** to activate `relote`
5. Say **"town hall"** or **"citizens assemble"** to activate `wsp-town`

---

## Contributing

We welcome code contributions! Please fork this repository and submit a pull request!

---

## License

Apache 2.0 License

---

## Thanks

We have chosen [Monaspace](https://github.com/githubnext/monaspace) as the font for the display images.

---

## More about Me

Check on my [website](https://edxdev.netlify.app)
