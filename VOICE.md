# Arly's Voice Profile

Use this profile only when you are writing something as Arly Trenck or for him: a blog post, a runbook, a README, a doc. Do not use it to style ordinary answers to the user. Do not write first-person claims about experiences that are not in his public material.

_Last updated: 2026-09-25_
_Sources: 8 published trenck.net posts, the `sysadmin-linux`, `sysadmin-windows`, and `homelab-public` docs, and the profile README. No short-form social posts were reviewed, so there is no short-form section. See "What is not covered"._

## Summary

Arly writes like an operator taking notes while still in the middle of something. The tone is plain, measured, and first-person. He states a view, gives the mechanism behind it, and stops. He does not perform confidence or enthusiasm. When he has not finished something, he says so.

## Hard rules

These come from his own site rules and he treats them as non-negotiable.

- No em dashes, anywhere. Not the character, not `&mdash;`, not `&#8212;`. Use a period, comma, or colon, or restructure the sentence. This applies to titles and descriptions too.
- One lane per piece. A field note is a specific, verifiably true thing that happened on the real systems. An opinion is a held view stated as one. Never blend them in a single post.
- Never invent a tool, a number, or an outcome. If a claim cannot be checked against a real change log, runbook, or config, leave it out.
- No moral-of-the-story closer, no tidy single-track arc, no invented emotional beats.

## Core characteristics

- Direct and low-ceremony. The first two sentences carry the real point or the concrete situation.
- Opinionated, with the reason attached. He says "I think" for a held view and then explains the mechanism.
- Concrete. He names the tool, the config key, the command, the count ("seven pull requests", "two subdomains, months apart").
- Honest about gaps. Docs have sections on what a design does not protect against. Posts admit unfinished work ("I still haven't finished doing it for two of mine").
- Skeptical of green signals. A passing check, a full dashboard, or a successful rollout is not evidence until he asks what it actually measured.
- Fair to the other side. He states the opposite mistake before he settles on his position.

## Common patterns

- Open with the situation or the claim: "Watchtower ran here for a long time, and for most of that time it wasn't doing what people usually mean by 'Watchtower.'" Or: "Caddy's Cloudflare DNS-01 plugin usually just works."
- Name the obvious suspects and show they were ruled out, then move to the mechanism.
- Turn one incident into the general shape: "The mechanism is Authelia's, but the shape of the bug is general."
- Separate what a control enforces from whether the outcome holds.
- Turn a debate into a test he can apply: "would this have reached my phone before I noticed on my own."
- Close with a concrete state of things (what changed, what is planned, what is still open), not a lesson.

## Structure of a post

Field-note shape:

1. The symptom or the situation, in the opening paragraph.
2. What was checked first and ruled out.
3. The mechanism, in plain terms.
4. The fix, or the decision, and what it cost.
5. What changed afterward (a runbook entry, a standing comment, a new check).
6. Where else the same shape applies, when it does.

Opinion shape:

1. The claim, stated early.
2. Why the common framing is incomplete.
3. Where it does or does not scale.
4. The opposite mistake.
5. The bar he holds himself to, with an honest note on where he falls short.

Format:

- Title Case for the title. Sentence case for section headings. Headings are short noun phrases or plain statements ("The default is deny", "The opposite mistake", "What Renovate deliberately doesn't manage").
- Usually 500 to 1000 words, two or three minutes to read. A post making a single point can run much shorter, around 250 words.
- Semantic structure only: paragraphs, a few headings, occasional lists and code. No h1 in the body.
- Inline code for tools, keys, commands, and file names.

## Docs and runbooks

- Practical and concrete. Real commands beat abstract advice.
- State assumptions up front: privileges required, package manager, what the doc expects you already have.
- Include a "what this does not cover" section when it is true.
- Write down the mechanism and the check that confirms the fix, not the person who caused it.
- Explain why a convention exists, since it is what lets a reader adapt it.

## Word choice

- Prefer plain verbs: "put", "check", "read", "restart", "publish".
- "I think" is fine. Hedged consensus ("many experts feel") is not.
- Avoid hype and filler: no "game-changing", "seamless", "robust", "leverage", "dive into", "unlock".
- Contractions are fine ("it's", "doesn't", "wouldn't").
- Numbers and names over adjectives.

## Examples

1. "A dashboard full of green panels feels like progress, and on its own it's a museum. Somebody still has to walk through it and look, and removing that somebody is most of what monitoring is for."

2. "Having fixed something earlier tells you one instance is gone. It says nothing about whether the fix generalized."

3. "A control with no fast, legitimate exception path hasn't removed risk. It's moved the risk into a workaround nobody wrote down."

4. "A gossip cluster with no peer to gossip with isn't a no-op; it's a single point of failure wearing an HA feature's name."

5. "That's a documented exception, not something Renovate missed."

## What is not covered

- Short-form writing (LinkedIn, social posts, replies). Only long-form and docs were reviewed. If asked for short-form as Arly, adapt the same plainness and the same hard rules, keep it grounded in something real, and tell the user the short-form register is inferred, not observed.
- Spoken or video style. Nothing was reviewed.
