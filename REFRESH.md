# REFRESH.md

How the knowledge files in this repo get updated. Follow this when refreshing by hand or when an automation does it for you.

## Sources (public only)

- New posts in the RSS feed: https://trenck.net/blog/feed.xml. Read the published post pages, not the feed summaries.
- Changes to the public repos: `arlytrenck/sysadmin-linux`, `arlytrenck/sysadmin-windows`, `arlytrenck/homelab-public`, and `arlytrenck/arlytrenck` (README, `docs/`, CHANGELOG, new scripts).
- Newly public repos owned by `arlytrenck`, if they are not forks and not archived.

## Off limits

- Private repositories, whatever their name (homelab, infrastructure, and employer repos among them).
- Blog drafts and anything not yet live on trenck.net. A post becomes a source the moment it is published, not before.
- Anything from an employer or client: names, systems, incidents, people.
- Hostnames, IP addresses, domains that are not public, tokens, keys, emails other than the public contact address, and account or vendor identifiers.
- Do not turn a placeholder from a sanitized doc (an `example.com` domain, a made-up LAN address) into a claim about a real system.

## What to update

| File | Update from | Rule |
|------|-------------|------|
| `OPINIONS.md` | new posts, new or changed docs | Merge into the existing section first. Add a new `###` entry only for a view that is genuinely new. Keep one or two evidence links per entry. |
| `VOICE.md` | new posts | Change it only if the new writing shows a durable pattern the file does not already capture. Otherwise update only the metadata lines. |
| `TOOLS.md` | public repos | Update script and doc counts, add new scripts to the problem tables, add newly public repos. Remove anything that was renamed, archived, or made private. |
| `ENTRY.md` | Arly's instruction | Do not change it automatically. It defines behavior. |
| `README.md` | Arly's instruction | Do not change it automatically. |

## How to update

1. Read the current file before editing it. Do not regenerate it from scratch.
2. Merge and tighten. A refresh that only appends will bloat the file. If a new post sharpens an existing opinion, rewrite that entry.
3. Every opinion must trace to something public. If you cannot link it, leave it out.
4. Keep the distinction between "Arly's practice" (what he does) and "Arly thinks" (what he says).
5. Never state a number, tool, or outcome that the source does not state.
6. Follow `VOICE.md` hard rules in the text you write. In particular, no em dashes.
7. Update the `Last updated` and `Sources` lines.
8. Run `scripts/check.sh` and fix everything it reports.

## Committing

- One commit per refresh, with a plain message that says what was added.
- No AI attribution in commit messages or pull requests. That is the convention across every `arlytrenck/*` repo.
- If nothing new was published since the last refresh, make no commit.

## The unattended runner

`scripts/refresh.sh` does the whole refresh on a schedule. The scheduler is an n8n Schedule Trigger that runs it over SSH. The script works in stages so the agent step is small and boxed in:

1. **Gate.** It snapshots the public sources: post URLs from the feed, the HEAD commit of each public repo, and the list of public repos. If that matches the saved baseline, it exits. Most days nothing runs and nothing costs anything.
2. **Fetch.** It downloads only what changed into `.sources/` (new post text, changed repo checkouts, commit logs) and writes `.sources/CHANGES.md`.
3. **Agent.** It runs `ARLY_AGENT_CMD` inside the clone with a fixed prompt. The agent reads `.sources/` and edits `OPINIONS.md`, `TOOLS.md` and `VOICE.md`. It gets no network and no shell.
4. **Verify.** Any change to another file, any new file, a file that shrank by more than 30 percent, or a failing `scripts/check.sh` resets the tree and exits non-zero. Nothing is pushed.
5. **Commit and push.** Only then does it commit, push, and move the baseline. A failed run leaves the baseline alone, so the next run tries again.

Exit codes: `0` nothing new or refreshed, `1` a check failed, `2` setup problem or no baseline, `3` a public source could not be read. A non-zero exit is meant to show up as a failed n8n execution.

Install on the host that runs the schedule:

1. Make sure the host can push to `arlytrenck/arly` (a deploy key with write access, scoped to this repo only).
2. Set `ARLY_AGENT_CMD` for the SSH command. It must read a prompt on stdin, edit files in its working directory, and be restricted to file read and edit tools.
3. Run `scripts/refresh.sh -s` once, while the knowledge files are current, to record the baseline.
4. Run `scripts/refresh.sh -n` to see what a run would do without changing anything.

`-f` forces a run when nothing looks new. Never run the agent step by hand against an unclean clone.
