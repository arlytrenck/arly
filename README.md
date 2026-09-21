<h1 align="center">/arly</h1>

<p align="center">
  <img src="assets/banner.png" alt="Arly Trenck, IT Systems Engineer and Infrastructure Architect" width="640" />
</p>

<h3 align="center">Build systems that hold up, and automate the work around them</h3>

Hi, I'm [Arly Trenck](https://trenck.net). I'm an IT systems engineer and infrastructure architect. My day job is enterprise IT: servers, networks, identity, security, and backup across 29 offices in Connecticut, New York, and Massachusetts. At home I run a homelab the way I run production, with the config in git, one command to rebuild the host, and backups I have actually restored from.

This `/arly` skill packages how I approach that work: the tools and runbooks I've published, and the opinions I've written down, so your agent can use them when it helps you with servers, networks, identity, monitoring, backups, rollouts, and troubleshooting.

It only knows what I've made public. See [what it won't use](#what-it-wont-use).

## Quick start

```sh
# install (global recommended)
$ npx skills add arlytrenck/arly -g

# in your agent
/arly why does my new reverse-proxy vhost return 403 for everyone?
/arly how should I roll out MFA to a multi-site company?
/arly is my backup setup actually a backup?
/arly which of your scripts audits SSH keys?
```

## How it works

The `/arly` skill file is thin on purpose. It loads four files from this repo and follows them.

```
/arly <question>
      │
      ▼
skills/arly/SKILL.md      loads the four files below (local clone first, raw GitHub otherwise)
      │
      ▼
ENTRY.md      how to route the question and how to work a task
TOOLS.md      my public repos, and which script or doc solves which problem
OPINIONS.md   my held views, each with a link to where I wrote it down
VOICE.md      how I write, used only when writing as me
      │
      ▼
a short, concrete answer that points at the runbook, script, or post behind it
```

Two habits carry through everything in `ENTRY.md`. Work read-only until the plan is clear, and don't call anything done until you have tested the way it will actually fail.

## What it won't use

- Private repositories, unpublished drafts, and anything from an employer.
- Hostnames, addresses, tokens, and account details. `scripts/check.sh` scans for them before a commit.

Where my public material does not cover a question, the skill says so and falls back to general knowledge.

## Keeping it current

The knowledge files are refreshed from what I publish: new blog posts, and changes to the public repos. The procedure and rules are in [`REFRESH.md`](REFRESH.md). Merge and tighten first, append only when something is genuinely new.

## Layout

| Path | What it is |
|------|------------|
| `skills/arly/SKILL.md` | The installable skill. Loads the files below. |
| `ENTRY.md` | Routing and task workflows. |
| `TOOLS.md` | Public tools and what each one solves. |
| `OPINIONS.md` | Durable viewpoints, with evidence links. |
| `VOICE.md` | Writing profile for when the agent writes as me. |
| `REFRESH.md` | How the knowledge files get updated, and what is off limits. |
| `scripts/check.sh` | Pre-commit guard: no em dashes, no private names, no secrets or LAN addresses. |

## Contributing

This is my own knowledge base, so it does not take pull requests. Bug reports, corrections, and suggestions are welcome as issues.

## Credit

The idea of a thin skill that loads a living, personal knowledge base comes from [kunchenguid/kun](https://github.com/kunchenguid/kun). Everything here was written from scratch from my own public work.
