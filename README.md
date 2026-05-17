
<div align="center">

![The Brand picture of Wasup](/assets/Wasup.png)

# Wasup Skill

![badge](https://img.shields.io/github/downloads/EdwardJoke/wasup/total?style=flat&color=174084) ![badge](https://img.shields.io/github/license/EdwardJoke/wasup?style=flat) ![badge](https://img.shields.io/github/stars/EdwardJoke/wasup?style=flat) ![badge](https://img.shields.io/github/last-commit/EdwardJoke/wasup?style=flat)<br/>
![GitHub Open Issues](https://img.shields.io/github/issues/EdwardJoke/wasup?style=flat) ![GitHub Contributors](https://img.shields.io/github/contributors/EdwardJoke/wasup?style=flat)

A collection of AI agent skills for task management and project documentation synchronization. Built to help developers and AI agents get out of task management troubles.

### ~ Introduce the new Feature of Wasup ~
*After I test **Relote** in [Hoz](https://github.com/EdwardJoke/hoz-vcs), it's now fully grown and ready for use* `News 05/07`<br/>
*Introduced **Reviewer** agent inside `wsp-opt`* `News 05/09`

---
</div>

## Features

- **wsp-opt** - Structured development workflow with `MoSCoW` (Must/Should/Could/Won't Have) prioritization, git integration, and atomic commits
- **wsp-sync** - Automated documentation sync that scans and updates outdated `.md` files
- **Relote** - The release note generator skill

---

## Quick Start

To get started with Wasup, follow these steps:

### Installation

#### Use skills manager from Vercel (Recommended)

```bash
# Use `npx skills`
npx skills add EdwardJoke/wasup

# Or you can download the `.zip` file directly (Not recommended)
# Because you will lost the automated update feature
```

### Usage (AI Agent Prompts)

These are **skill names** that auto-trigger when you say the keywords to your AI agent:

1. Say **"start a new project"** or **"let's build [feature]"** to activate `wsp-opt`
2. Say **"generate changelog"** or **"relote"** to activate `relote`
3. Say **"sync up"** or **"sync docs"** to activate `wsp-sync`

---

## Contributing

We welcome code contributions! Please fork this repository and submit a pull request!

---

## License

Apache 2.0 License

---

## Thanks

We have chosen [Monaspace](https://github.com/githubnext/monaspace) as the font for the display images.
