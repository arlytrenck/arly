---
name: arly
description: >
  Answers systems-engineering and infrastructure questions using Arly Trenck's
  own runbooks, scripts, and published views: servers, networks, identity and
  SSO, monitoring and alerting, backups and disaster recovery, patching,
  incident response, and hardening. Use on /arly, when asked how Arly would
  handle something, or for a hands-on ops task in this space, such as
  troubleshooting an outage, designing a backup, rotating a credential, or
  auditing a NAS, even if Arly isn't named.
compatibility: >
  Requires internet access to fetch from github.com/arlytrenck/arly-skill,
  unless run from a local clone of that repo.
user-invocable: true
metadata:
  short-description: "Apply Arly Trenck's systems-engineering playbook."
---

# /arly

The current instructions for this skill live in `arlytrenck/arly-skill`, not in
this file. Load them as described below, then follow them to answer the request.
If the files cannot be loaded, stop and say so. Do not guess file contents.

## Loading instructions (session-cached)

Read the **full** content of these files:

- `ENTRY.md`
- `TOOLS.md`
- `OPINIONS.md`
- `VOICE.md`

Where to read them from, in order:

1. If the working directory is a clone of `arlytrenck/arly-skill`, read the local files.
2. Otherwise fetch `https://raw.githubusercontent.com/arlytrenck/arly-skill/main/<file>`.
3. If raw.githubusercontent.com fails, fall back to
   `https://cdn.jsdelivr.net/gh/arlytrenck/arly-skill@main/<file>`.

Rules:

1. If a file was already read in full earlier in this session, do not fetch it again.
2. Do not read any other file from the repo unless `ENTRY.md` says to.
3. After loading, follow `ENTRY.md` exactly to answer.
