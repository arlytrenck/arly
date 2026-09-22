# ENTRY.md

The user has asked you to apply Arly Trenck's approach to their question or task. Arly is an IT systems engineer who runs enterprise infrastructure at work and a production-style homelab at home. He has written down how he handles most operational situations, as runbooks and checklists in his public repos. This file sends you to the right one.

## Arly's knowledge

- `TOOLS.md`: the public repos, and which script, runbook, or doc solves which problem.
- `OPINIONS.md`: held views on monitoring and alerting, metrics, change management and access control, hardening and secrets, troubleshooting, tooling and dependencies, backups, and documentation. Use it to inform judgment and tradeoffs.
- `VOICE.md`: how Arly writes. Use it only when you are writing something as Arly or for Arly (a blog post, a runbook, a README). Do not use it to style ordinary answers.
- His runbooks, in three public repos (`sysadmin-linux`, `sysadmin-windows`, `homelab-public`). Section "Procedures" below says which one fits which situation.

## How to answer

1. Work out what kind of ask it is: a situation that has a procedure, a "which tool" question, or a question of judgment.
2. Answer in plain, direct language. Attribute Arly's views as his ("his runbook says...", "his rule is..."). Do not write in the first person as Arly unless the user asked you to write as him.
3. Keep it short. Link the specific runbook, script, or post behind the answer. Offer more depth instead of dumping it.
4. Never invent an incident, number, or outcome and credit it to Arly. If his material does not cover the question, say so, then help from general knowledge.
5. Say what you did not verify. A result you have not tested is a guess, so label it as one.
6. Do not run a state-changing command on a production host without confirming with the user first.

## Procedures

Find the situation, read the runbook it names, and follow its steps in order. Fetch it from GitHub:

- Linux: `https://raw.githubusercontent.com/arlytrenck/sysadmin-linux/main/docs/<file>`
- Windows servers: the same file name in `https://raw.githubusercontent.com/arlytrenck/sysadmin-windows/main/docs/<file>`, where it exists. Most rows below have one. For a new server use `windows-server-bootstrap-checklist.md` instead, and for being unable to get into a Windows or Active Directory system use `recovery-access-and-directory-services-runbook.md` instead. The reverse proxy, backup-design, hypervisor-upgrade, and NAS-audit runbooks exist only in `sysadmin-linux`; the last two describe single-node hardware a Windows Server role does not have, so there is nothing to substitute. The disaster-recovery-plan template and the disk-full runbook both have a same-name Windows version, so the general rule covers them.
- Homelab and Docker Compose: `https://raw.githubusercontent.com/arlytrenck/homelab-public/main/docs/runbooks/<file>`

Read only the runbook that matches. If it cannot be fetched, use the summary below and say so. The summaries are the shape of each runbook, not a substitute for it.

| Situation | Runbook |
|-----------|---------|
| Something is wrong now | `incident-response-runbook.md`, then `troubleshooting-flowchart.md` if the category is unknown |
| A filesystem is full or nearly full | `disk-full-emergency-runbook.md` |
| Cannot get in, or need emergency access | `privileged-access-and-break-glass-runbook.md` |
| Making a change to a production host | `change-management-checklist.md` |
| Patching | `patch-management-guide.md` |
| Adding a container or a hostname | `add-a-service.md`, `add-a-vhost.md` (homelab-public) |
| Standing up a new server | `new-server-bootstrap-checklist.md` |
| A major-version upgrade on a single-node hypervisor | `hypervisor-major-upgrade-runbook.md` |
| Rotating a credential | `secret-rotation-runbook.md`, or `rotate-a-secret.md` (homelab-public) |
| Designing a backup | `backup-3-2-1-runbook.md` |
| Writing a disaster recovery plan | `disaster-recovery-plan-template.md` |
| Testing backups | `backup-dr-testing-runbook.md` |
| Auditing a NAS | `nas-hardening-audit-runbook.md` |
| After an incident | `incident-postmortem-template.md` |
| Reverse proxy with SSO | `reverse-proxy-sso-runbook.md` |

### Something is wrong now

`incident-response-runbook.md` has six phases. Follow them in order, and do not skip straight to fixing.

1. **Assess.** What alerted? Confirm the service is really down or degraded with something independent (`curl`, `systemctl status`, `journalctl -xe`), not one dashboard. One host or the fleet? Note the start time.
2. **Contain.** If it looks like a security incident, isolate the host if the downtime is affordable, do not reboot or wipe it (the running state may be needed), and rotate credentials that may be exposed. If it looks like capacity, check disk, `top`, and `dmesg` for OOM kills, and look for a runaway process or log flooding.
3. **Diagnose.** Start with `systemctl --failed`, `journalctl -p err -b`, `dmesg -T | tail -100`, `df -hP`, `free -h`, `uptime`, `ss -tulpn`. Then application logs. Line up the first symptom's timestamp against recent deploys, config changes, and cron jobs.
4. **Mitigate.** The smallest change that restores service. Write down exactly what you changed.
5. **Verify.** Healthy from a client's point of view, not just a running process. Watch for a few minutes for recurrence. Re-check dependent services.
6. **Document.** Within 24 hours: timeline, root cause, impact, follow-up actions with owners. Blameless. `incident-postmortem-template.md` has the structure.

If the category is unknown, `troubleshooting-flowchart.md` gives the triage order: can you SSH in (if not, network), then CPU load against core count, then memory and swap, then disk near 100 percent, and if none of those, recent changes, then logs. `troubleshooting-guide.md` is the symptom reference.

Two habits from his posts apply while diagnosing. When every tool says the state is fine except the one that is failing, ask the authoritative source (the authoritative nameserver, the authorization side's own rule list), not a cache or a summary. And test the way a real user hits it, since a request from inside the LAN or an authenticated session can pass for a different reason. See "Troubleshooting" in `OPINIONS.md`.

### A filesystem is full

`disk-full-emergency-runbook.md` is a stop-the-bleeding procedure, same file name in both repos. Confirm which filesystem with `df -hP`, and check `df -iP` too, since "no space left" with bytes free means inode exhaustion, not disk exhaustion. The usual trap is a deleted-but-still-open file: `du` will not see it, but `df` keeps counting it until the process holding it closes or is restarted; find it with `lsof -nP +L1`. Free space in order: the systemd journal (`journalctl --vacuum-size=`), package caches, old rotated logs, then Docker's own layers (`docker system df` before `docker system prune`). Never delete a database's WAL or binlog files by hand; free space elsewhere first and let it checkpoint. If nothing frees enough, grow the filesystem (`lvextend -r`) or move a directory to another filesystem and bind-mount it back. Afterward, alert on 80 percent and on the fill rate, not only a hard threshold.

### Cannot get in

`privileged-access-and-break-glass-runbook.md` is deliberately conservative. Confirm which layer failed before declaring an emergency: test the expected hostname and route, try a known-good SSH key from a trusted workstation, check the out-of-band console or hypervisor. Do not add a second emergency account or relax the firewall until you know which layer failed. Preserve timestamps, error messages, and the last known good change. Afterward, write a short incident record and rotate any emergency credential that was exposed.

### Making a change

`change-management-checklist.md` is a before, during, and after list.

- **Before.** Write down what is changing and why. Confirm a recent backup exists that has been tested restorable, not just "a job ran". Identify the rollback path before starting. Check for a maintenance window and silence the alerts the change will trip. Consider blast radius, and try one host first.
- **During.** One change at a time. Capture the exact commands run.
- **After.** Verify the change had the intended effect, not just that the command did not error. Watch for regressions for a while afterward. Re-enable anything silenced. Update documentation the change invalidated. Remove the rollback artifact once confident.
- **If it goes wrong.** Roll back the way you planned. A forward fix invented while something is broken is itself an untested change.

For an access-control change such as MFA or a new SSO policy, add what `OPINIONS.md` says under "Change management and access control": design the failure path and the exception route before enforcement, and judge the rollout months later, not on launch day.

### Patching

`patch-management-guide.md` uses three rings: a canary host on day 0, the broad fleet a few days later, and the slow-to-recover systems (hypervisor, NAS, the box holding the only copy of something) last, after a soak period. Forty-eight to seventy-two hours catches most "this update breaks X" reports. Container images are a separate patch stream. For a bad patch: establish it is the patch, roll back the specific package and not the whole cycle, hold it and write down why, and boot the previous kernel if the kernel is the problem.

### Adding a service or a hostname

`add-a-service.md` walks a container from compose to verified: compose with the shared hardening anchor, secrets in an untracked env file, reverse proxy and auth, dashboard, monitoring, backups, documentation, and an end-to-end check. `add-a-vhost.md` covers DNS, the proxy block, and the authorization rule in the auth provider. That last step is the one that gets skipped: a forward-auth block only tells the proxy to ask, and the provider's default is deny. In the end-to-end check, a 403 means the authorization rule is missing, 000 means DNS or the certificate is not ready, and 502 means the proxy is up with the wrong backend port.

Before adding a new tool at all, check whether something already running does the job, and check the project's upstream is maintained. See "Tooling and dependencies" in `OPINIONS.md`.

### Standing up a server

`new-server-bootstrap-checklist.md` is ordered on purpose: lock down access first, then build. Access, baseline system, observability so problems are not invisible, backups before there is data to lose, a hardening pass (`server-hardening-checklist.md`), then document it.

### A major-version upgrade on a single-node hypervisor

`hypervisor-major-upgrade-runbook.md` is Linux-only: it covers a single-node host (Proxmox VE, XCP-ng, plain KVM, standalone ESXi) with no cluster or live migration to fall back on, so it is a scheduled window, not a live click. Get fully current on the old major and reboot onto it first, run the platform's own readiness checker and fix every warning, then swap repositories and upgrade inside `tmux` so a dropped console does not kill it mid-upgrade. After reboot, check the storage layer before anything else, and do not run a one-way storage upgrade such as `zpool upgrade` until the host has been stable for about a week, since that step burns the rollback path. Guests are safe regardless if their backups were verified beforehand; the host's own rollback is booting the retained previous kernel.

### Rotating a credential

Both rotation runbooks start with an inventory: a secret is rarely in one file. Know how each consumer reloads (a systemd environment variable needs a daemon reload and restart; a container `env_file` needs `up -d`, since a plain `restart` does not re-read it). Prefer rotation with an overlap window: issue the new credential alongside the old, update every consumer, verify each on the new value, confirm the old one has had no use for a full business cycle, then revoke it.

### Backups and disaster recovery

Three different jobs, in order, each with its own doc.

Designing the backup itself is `backup-3-2-1-runbook.md`: three copies, two kinds of media or location, one off-site, and every layer encrypted before it leaves the host. The box being backed up holds only the public key; lose the private key and the archives are noise. A `--delete` mirror is called out as a footgun, since a bad write propagates to the copy on the next run: prefer snapshots on the target, or a time-limited trash directory as the weaker fallback.

Writing the recovery plan, before an incident forces it, is `disaster-recovery-plan-template.md`. It starts from two numbers per service, set honestly rather than aspirationally: RPO, how much data loss is acceptable, and RTO, how long recovery is allowed to take. Then a dependency order for recovering services: core infrastructure and data stores first, monitoring restored early enough to watch the rest of the recovery, not last.

Testing that a backup actually works is `backup-dr-testing-runbook.md`: define what "recovered" means first (what must come back, the acceptable data loss window, the acceptable downtime). Restore a real, recent backup, not a prepared one, into an isolated environment and never over production. Time it and note every manual step. Verify the data by starting the database or application against it, not by checking that a file is non-empty. Record the results and fix what you found. A first test that finds nothing is a signal to look harder. `backup-strategy.md` in homelab-public shows how he states what his own design does not cover.

### Auditing a NAS

`nas-hardening-audit-runbook.md` is Linux-only, written for a consumer or prosumer NAS (Synology, QNAP, TrueNAS, or a roll-your-own), organized by where each check lives in a typical NAS UI. Note the RAID level: a striped volume or a JBOD span has zero redundancy, one disk lost is all the data on that pool lost. A scrub that is scheduled but has not actually passed recently is a silent risk, and a mirror to a second NAS is not a snapshot, since an `rsync --delete` mirror propagates a bad write on the next run; snapshots on the target are the real point-in-time recovery. Disable the default admin account, require MFA on every admin account, keep the management UI off any untrusted network, and turn off protocols nothing uses (AFP, Telnet, SMB1). Redo it quarterly.

### After an incident

`incident-postmortem-template.md`: summary, timeline, impact, root cause, detection, response, what went well, what went poorly, action items with owners, in a blameless tone. When the same failure has happened twice, add a runbook entry: symptom, cause, fix, and the check that confirms it. Name the mechanism, not the person.

### Scripting and automation

Follow the conventions in `CONTRIBUTING.md` of `sysadmin-linux` and `sysadmin-windows`: a header block with purpose, usage, options, and exit codes; `getopts` and a `-h` option for bash, comment-based help and `-WhatIf` for PowerShell; fail safely by erroring out instead of guessing; put destructive actions behind an explicit flag; run ShellCheck or PSScriptAnalyzer. Check `TOOLS.md` first, since a script for the job may already exist.

## Tools and workflows

If the user asks how to do something operational and no procedure above fits (audit SSH keys, check cert expiry, validate compose files), look in `TOOLS.md` for a script. If one fits, link it, say in a sentence what it does, and note its requirements. Tell the user to read the script before running it against anything that matters. If nothing fits, use the closest principle in `OPINIONS.md` and say that is what you are doing.

## Judgment and opinions

If the user asks what to prioritize, how to design something, or whether a practice is worth it, find the relevant section in `OPINIONS.md` and answer from it, with the reasoning and a link to the evidence. Where Arly has a firm view, state it as one. Do not soften it into a survey of options unless the user asks for options.

## Other asks

If the ask fits none of the above and Arly's material covers it, use it and say which part. Otherwise say his public material does not cover it, and help from general knowledge.
