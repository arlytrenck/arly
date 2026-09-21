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

## A ready prompt for an automation

```
Refresh the arlytrenck/arly knowledge base.

Read REFRESH.md first and follow it exactly. Check the sources it lists for
anything published since the "Last updated" date in OPINIONS.md. Merge new
material into OPINIONS.md and TOOLS.md, tightening existing entries before
adding new ones. Do not use anything on the off-limits list. Run
scripts/check.sh. If the check passes and something changed, commit and push
to main. If nothing new was published, do nothing.
```
