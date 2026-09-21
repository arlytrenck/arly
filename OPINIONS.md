# OPINIONS.md

A compact map of Arly Trenck's viewpoints, taken only from what he has published: his blog at trenck.net, the READMEs and docs in his public repos, and his GitHub profile. It is written for use as LLM context, so repeated points are consolidated and evidence links are kept to one or two per entry.

Where an entry says "Arly's practice", it is describing what he does on his own systems. Where it says "Arly thinks", it is a stated view. Do not present either as more than that.

_Last updated: 2026-09-21_
_Sources: 7 published blog posts (2026-09-08 through 2026-09-21), `homelab-public` docs, `sysadmin-linux` and `sysadmin-windows` READMEs and CONTRIBUTING, the profile README._

## Monitoring and alerting

### Monitoring is only real if it reaches a person

Arly thinks the test of whether a system is monitored is "would I find out about a real problem without going looking for it", not "can I query this metric". A dashboard full of green panels is a museum: somebody still has to walk through it. Removing that somebody is most of what monitoring is for.
He does not think this is a homelab-scale problem. A well-instrumented enterprise system with no alerting on the metrics that matter is discovered down the same way an unmonitored one is, by someone noticing the service is gone.
The bar he holds his own systems to: would this have reached my phone before I noticed on my own. He admits he has not finished answering that for two of his own systems.
Evidence: https://trenck.net/blog/monitoring-without-alerting-is-a-museum/

### Alert on a handful of things you trust

Alerting on everything is the opposite mistake. It buries real signal until dismissing notifications becomes a reflex, and an alert nobody trusts does the same work as no alert. He treats "what deserves to page someone" as a design decision, and prefers a handful of alerts he trusts completely over a hundred he has learned to ignore.
Evidence: https://trenck.net/blog/monitoring-without-alerting-is-a-museum/

### Keep one monitor independent of the thing it watches

In his stack, Uptime Kuma is deliberately separate from Prometheus, so black-box checks keep working when Prometheus is down. Backup freshness is a metric, with an alert when any job's last success goes stale, so a job that quietly stopped is visible.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/monitoring-and-alerting.md

### A feature meant for resilience can create the failure it exists to catch

Alertmanager's gossip clustering, left on with a single instance, wedged the dispatcher after failed deliveries and silently stopped all alerts until a restart. His summary: a gossip cluster with no peer is a single point of failure wearing an HA feature's name. Check what a default is actually doing for your topology.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/lessons-learned.md

### Scope self-healing deliberately

Auto-restart is applied to stateless or easily resumed services, where a silent recovery beats a 2am page. Databases are excluded because restarting mid-transaction can do more harm than a human investigating. The identity provider (Authelia) is excluded because an auth outage should be seen immediately, not auto-remediated. The alert-delivery path is excluded because a mis-firing healthcheck plus auto-restart could loop or mask the very outage it should report.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/hardening-conventions.md

## Metrics and reporting

### Closure speed measures throughput, not health

Arly thinks a fast-closing ticket queue is a weak headline health number, even though monthly reports tend to treat it as one. A quickly closed ticket can mean the cause was fixed. It can just as easily mean the symptom went quiet long enough to hit "resolved", after which the same request returns under a new number and counts as a fresh success.
Evidence: https://trenck.net/blog/ticket-metrics-measure-activity-not-health/

### Prefer recurrence, and be honest about what it costs

The metric he would use instead is repeat-ticket rate by root cause, one level below the surface category. A downward trend there means the problem stopped. It is more work to produce: tickets have to be grouped by root cause, not by the label typed at intake, and one underlying problem often shows up as several unrelated tickets. Closure time already exists as a column, while recurrence is a project, so the report shows closure time. He says he has no clean way to produce it yet, and that doing the grouping by hand once a month is the kind of task that does not survive a busy month.
Evidence: https://trenck.net/blog/ticket-metrics-measure-activity-not-health/

## Change management and access control

### An access-control rollout is a change-management project

Arly thinks the technical work of MFA, conditional access, or a new SSO policy is the small part: a few settings, a policy document, a test account. What decides success is the organizational effort around it. Rollouts break on the traveling employee with no signal, the shared workstation where "whose phone is this" has no answer, the person on leave when enforcement lands, and the manager who hears about it from a locked-out employee before IT tells them.
Evidence: https://trenck.net/blog/security-rollouts-fail-on-people/

### Design the failure path first

The first design question is what happens when this fails for a legitimate person outside business hours, and how long they are stuck. If the answer is "until the help desk opens", the rollout is not ready. A control with no fast, legitimate exception path does not remove risk. It moves the risk into a workaround nobody wrote down. Build the exception path before enforcement, not after the first ticket, so its failure mode is an admin making a five-minute judgment call.
Evidence: https://trenck.net/blog/security-rollouts-fail-on-people/

### Judge a rollout six months later

A rollout that grades itself a success on launch day is measuring the wrong thing. Arly's metric is whether it is still on and unmodified six months later. What goes wrong shows up slowly: shared logins because individual accounts were too much friction, an exception list that grew until it swallowed the policy, a "temporary" bypass that outlived its approver. Pilot with a visible, cooperative group, and announce the timeline further ahead than feels necessary.
Evidence: https://trenck.net/blog/security-rollouts-fail-on-people/

### Controls are worth doing firmly, and are not finished when configured

He is not against MFA, conditional access, or tightly scoped SSO. He thinks they are worth doing firmly. His pushback is on calling any of them finished the moment they are configured: the technology enforces a policy, and whether the policy holds depends on months of change management nobody scoped time for.
Evidence: https://trenck.net/blog/security-rollouts-fail-on-people/

## Defaults, hardening, and secrets

### The default is the thing to go check

Two lessons from his own systems point the same way. Authelia's `default_policy` is deny, so a new subdomain with no matching rule is locked out for everyone. Container ports default to `0.0.0.0`, and a media-library manager's VNC port (5900) sat unauthenticated on `0.0.0.0`, reachable from the LAN, until an audit caught it. His rule: find out what the default is, then look at what is actually bound or matched, on a schedule.
Evidence: https://trenck.net/blog/authelia-two-file-access-control-bug/ and https://github.com/arlytrenck/homelab-public/blob/main/docs/lessons-learned.md

### One baseline on every service

Every service in his stack sets `no-new-privileges`, a restart policy, a healthcheck, a timezone, and log rotation. Every service has a memory limit and a process limit, sized as ceilings at roughly three to four times observed use. Ports publish on `127.0.0.1` behind a reverse proxy, or on a specific LAN address, never `0.0.0.0`. Databases get a long stop grace period so they checkpoint cleanly.
Evidence: https://github.com/arlytrenck/homelab-public#conventions

### Secrets stay out of tracked files, and out of scratch files

Secrets never live in a compose file or any tracked file. Each stack reads an untracked env file with restrictive permissions, and documents every key, without values, in an `.env.example`. He also counts untracked plaintext as a problem: two credential files left on disk as quick notes-to-self were found in an audit. If you write a password down during setup, move it to a password manager and delete the scratch file.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/lessons-learned.md

## Troubleshooting

### One change, two places: verify both

A reverse proxy handing the access decision to a separate service is a two-step change. Caddy's `forward_auth` declares where to ask. Authelia's `access_control` declares what the answer is. Nothing shows both at once, so a correct-looking proxy block can sit in front of a rule that does not exist. The shape generalizes to nginx `auth_request` and Traefik `forwardAuth`. After adding a protected route, read the authorization side's own rule list and find the route by name.
Evidence: https://trenck.net/blog/authelia-two-file-access-control-bug/

### Fixing one instance does not tell you the fix generalized

When the same bug appeared twice in a day, he fixed both and moved on without asking why. Later he found the same gap on three more vhosts. In his words: "Having fixed something earlier tells you one instance is gone. It says nothing about whether the fix generalized." He now keeps a checklist next to the most recently added vhost listing both halves of the change.
Evidence: https://trenck.net/blog/authelia-two-file-access-control-bug/

### Test the way a real user hits it

Testing a protected route means an actual browser that is not already authenticated. `curl` from inside the LAN can pass the real check for an entirely different reason.
Evidence: https://trenck.net/blog/authelia-two-file-access-control-bug/

### Ask the authoritative source

When DNS looks right in every tool except the one failing, query the authoritative nameserver directly, not a public resolver. A resolver returns what it last cached, which is the wrong answer when the origin data never finished publishing. Rule out the obvious suspects first (token scope, a typo, propagation delay), then stop guessing.
Evidence: https://trenck.net/blog/cloudflare-stuck-dns-publish-fix/

### A fix downstream does not restart what is upstream

After correcting the DNS record, Caddy's ACME client was still backing off exponentially from its earlier failures, so fixing DNS did not trigger a retry. A restart cleared the backoff. When you repair a dependency, check whether the consumer is waiting out its own delay.
Evidence: https://trenck.net/blog/cloudflare-stuck-dns-publish-fix/

### Same failure twice earns a runbook entry

The stuck-DNS fix worked twice, months apart, on different subdomains. It went into the runbook: recreate the record, confirm against the authoritative server, restart Caddy. His stated payoff is five minutes next time instead of an afternoon second-guessing a token that was never the problem.
Evidence: https://trenck.net/blog/cloudflare-stuck-dns-publish-fix/

### Check the network layer before blaming the firewall

If a public-facing service works from outside but fails from inside the LAN, check for NAT hairpinning before assuming a firewall or DNS misconfiguration. The fix is a local resolver overriding those specific names to the LAN address, not a change to the service.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/lessons-learned.md

## Tooling and dependencies

### Stop at the second fork

The upstream of the Watchtower he ran (`containrrr/watchtower`) is abandoned, and his stack had already moved to the community `nickfedor/*` fork to keep receiving updates. Fork-hopping a second time is where he stops and picks a different tool.
Evidence: https://trenck.net/blog/watchtower-to-renovate/

### An update should arrive as a diff, a CI run, and a changelog

A phone notification that an image tag moved says nothing about what changed, does not check that the new version starts, and leaves no record. He moved image updates to Renovate pull requests that run the existing validation workflow before he merges. Nothing auto-applies: the `docker compose up -d` is always a deliberate human action.
Evidence: https://trenck.net/blog/watchtower-to-renovate/ and https://github.com/arlytrenck/homelab-public/blob/main/docs/hardening-conventions.md

### Let the grouping encode the judgment calls

Rolling `:latest` tags are digest-pinned and batched into one weekly PR, since they have no changelog to read. Version-tagged images get their own PR with the changelog attached. Components that must stay in lockstep move as a group. Authelia, Vaultwarden, and major versions of Postgres and Valkey are flagged individually for a manual release-notes read, because taking those updates is a decision about data formats or auth behavior. Version bumps stay manual for good. Auto-merge is planned only for digest-only bumps, after a few clean weeks.
Evidence: https://trenck.net/blog/watchtower-to-renovate/

### Document the exceptions

What Renovate does not manage (anything in `.env`, so Immich's version) is a documented exception, not a gap. A PR nobody merges without reading the notes is just noise. The older registry-digest script stays as an out-of-band check on what the primary tracker misses.
Evidence: https://trenck.net/blog/watchtower-to-renovate/

### Do not add a second tool if the first already does the job

He deployed Rundeck to get run history and a UI for cron-driven backups, then removed it the same day. n8n, already running, could do the same job (trigger a script over SSH on a schedule, log it, alert on failure) at no extra memory. Rundeck's real advantages, multi-user RBAC and audit policies, answered a question a single-operator setup never asked.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/lessons-learned.md

## Backups and recovery

### A backup you have not restored is a belief

Arly's practice is a monthly restore drill that restores a canary set, decrypts the newest database dump, loads it into a throwaway database container, and counts rows. That is a real "does it restore", not "does the file exist". Results are pushed as a notification, and backup freshness is a metric with an alert.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/backup-strategy.md

### State what the design does not protect against

His backup doc has a section on the gaps. Two copies in one physical location is not 3-2-1, and a nightly mirror faithfully replicates a deletion or corruption within about a day. He names the missing leg (an off-site target) instead of implying coverage he does not have. Mirrors that delete carry a `--max-delete` circuit breaker and a trash directory.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/backup-strategy.md

### Layer backups by what is being protected

Config, databases, secrets, and history each get a mechanism that fits: nightly config sync, dumped-and-encrypted databases with rotation and checksums, encrypted secret bundles, and a versioned repository with retention and an integrity check on every run.
Evidence: https://github.com/arlytrenck/homelab-public/blob/main/docs/backup-strategy.md

## Documentation and reuse

### Scripts get read before they get run

His scripts are built to be read: each documents its own options, and the PowerShell ones carry comment-based help and `-WhatIf`. Contributions are held to the same bar: match the header style, fail safely, prefer erroring out to guessing, and put destructive actions behind an explicit flag.
Evidence: https://github.com/arlytrenck/sysadmin-linux#why-this-repo-exists and https://github.com/arlytrenck/sysadmin-linux/blob/main/CONTRIBUTING.md

### The docs get opened more than the scripts get run

Most days the work is a command whose shape is familiar but not the exact flags, so cheatsheets are used more than any single script. Docs favor concrete commands over abstract advice, and state their assumptions (privileges, package manager).
Evidence: https://github.com/arlytrenck/sysadmin-linux#why-this-repo-exists

### Parameterize, then publish

The step that makes a script reusable across a few hosts (parameterizing paths, thresholds, package manager) is most of the work to make it reusable by others, so he publishes instead of keeping it private. Vendor-specific tooling is out of scope, because it mostly helps people already paying that vendor. Split the toolkit by platform, not by task, so generalizing stays cheap and each repo needs one shell and one linter.
Evidence: https://github.com/arlytrenck/sysadmin-linux#why-this-repo-exists

### Write for whoever hits the problem next

His blog skips getting-started material, since good writing already exists, and covers what comes after: what you set up correctly a year ago that breaks in a way the logs do not explain, or the tool that was right when chosen and stopped being right without saying so. He writes while still in the middle of something, so posts read as notes. Some are narrow enough to be a note to himself.
Evidence: https://trenck.net/blog/welcome-to-the-blog/

## Practice and craft

### Run the homelab like production

Config in git, one command to rebuild the host, backups actually restored from, hardened Compose stacks behind a reverse proxy, and alerting that reaches a phone. Arly treats the homelab as practice for the work he does at the enterprise scale, and calls out his own gaps in public.
Evidence: https://github.com/arlytrenck/arlytrenck and https://trenck.net/blog/welcome-to-the-blog/

### Say when it is an opinion

His writing keeps two lanes apart: field notes about a specific thing that happened on the real homelab, and opinions with no single incident behind them. When he is giving an opinion, he says so instead of hedging it into something that sounds like consensus.
Evidence: https://trenck.net/blog/welcome-to-the-blog/
