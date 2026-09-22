# TOOLS.md

Public things Arly Trenck owns: public, not archived, not a fork. Use this file to know what exists and what it is for before reaching for something else.

Every repo below is under `https://github.com/arlytrenck/`. Default branch is `main`. Private repositories are intentionally not listed. `trenck.net` is a website, not a repo you can clone.

## sysadmin-linux

https://github.com/arlytrenck/sysadmin-linux

A toolkit of Linux server administration scripts, runbooks, and reference docs, gathered from homelab and small-fleet operations. 39 bash scripts and 48 docs. Bash 4+ and GNU coreutils, checked with ShellCheck in CI.

It solves the "same problem on a second host" problem. Each script started as a one-off, then had its paths, thresholds, and package manager parameterized so it works elsewhere. Every script documents its own options with `-h`, and scripts fail safely rather than guessing.

Clone it, read a script, then run it with `-h` first. Review the source before running anything against a production host. Vendor-specific tooling is out of scope by design.

### Problem to script (Linux)

| Problem | Script |
|---------|--------|
| Who has a path to root | `sudo-access-audit.sh` |
| Weak or shared SSH keys | `ssh-key-audit.sh` |
| General host security sweep (SUID, world-writable, sudoers) | `security-audit.sh` |
| What is listening, versus what should be | `listening-ports-audit.sh` |
| Disk encryption at rest | `luks-encryption-audit.sh` |
| Do backups exist, are they recent, do they pass an integrity check | `backup-verify.sh` |
| Rotating backups with retention | `backup-rotate.sh` |
| Encrypted off-host backup copy | `age-backup.sh` |
| Dump every database container across compose stacks | `stack-db-dump.sh` |
| TLS certificate expiry, live host or file | `cert-expiry-check.sh` |
| Every ACME cert on the box (Caddy, certbot, acme.sh, Traefik) | `acme-cert-report.sh` |
| Validate compose files across a directory | `compose-validate.sh` |
| Running containers that drifted from what compose declares | `compose-drift.sh` |
| Containers running as root, privileged, unbounded, or restart-looping | `docker-container-audit.sh` |
| Containers with no healthcheck or an unhealthy one | `healthcheck-audit.sh` |
| Risky bind mounts (writable `/etc`, `docker.sock`) | `bind-mount-audit.sh` |
| Newer image digests than what is pinned or running | `compose-image-updates.sh` |
| Generate or verify `.env.example` from compose variables | `compose-env-example.sh` |
| Disk health (mdadm, SMART) | `raid-smart-health-check.sh` |
| Memory and swap pressure, OOM kills | `swap-memory-pressure-check.sh` |
| Clock drift | `time-sync-check.sh` |
| Reboot waiting to apply | `pending-reboot-check.sh` |
| Error-rate spikes against a baseline | `log-anomaly-scan.sh` |
| Snapshot the config so it lives in git | `system-snapshot.sh`, `nightly-git-mirror.sh` |
| Cron and timers across the system | `cron-audit.sh` |
| Who is on the box, who was recently, failed logins | `user-activity-report.sh` |
| Filesystem usage and the biggest directories, non-zero exit over a threshold | `disk-usage-report.sh` |
| Runaway or zombie processes (read-only by default) | `process-watchdog.sh` |
| Are these systemd units active, optionally restarting failed ones | `service-health-check.sh` |
| First-pass network sweep: interfaces, routes, sockets, DNS, reachability | `network-diagnostics.sh` |
| Fail2ban, SELinux or AppArmor, ClamAV: present and healthy | `endpoint-protection-status-check.sh` |
| Snapshot the active firewall ruleset (nftables, iptables, ufw) | `firewall-rules-dump.sh` |
| Installed packages, diffed against a baseline | `package-inventory.sh` |
| Snapshot Tailscale state as redacted JSON | `tailscale-export.sh` |
| Export Grafana dashboards, datasources, and alerting to JSON (read-only) | `grafana-dashboard-export.sh` |
| Apply package updates and log the result | `update-and-patch.sh` |
| Compress and delete old logs | `log-cleanup.sh` |
| Create, lock, or remove a local user | `user-mgmt.sh` |

These change the host: `update-and-patch.sh`, `log-cleanup.sh`, `user-mgmt.sh`, and `service-health-check.sh` when it is told to restart. Read them before running them anywhere that matters.

### Docs worth knowing (Linux)

Runbooks and checklists: `incident-response-runbook.md`, `disk-full-emergency-runbook.md`, `secret-rotation-runbook.md`, `privileged-access-and-break-glass-runbook.md`, `backup-3-2-1-runbook.md`, `backup-dr-testing-runbook.md`, `reverse-proxy-sso-runbook.md`, `hypervisor-major-upgrade-runbook.md`, `nas-hardening-audit-runbook.md`, `change-management-checklist.md`, `new-server-bootstrap-checklist.md`, `server-hardening-checklist.md`.

Guides and templates: `troubleshooting-guide.md` with `troubleshooting-flowchart.md`, `monitoring-alerting-guide.md`, `patch-management-guide.md`, `container-security-guide.md`, `incident-postmortem-template.md`, `disaster-recovery-plan-template.md`, `single-node-homelab-reliability.md`.

Also: `backup-restore-drill.md`, `database-backup-restore-guide.md`, `config-snapshots.md`, `config-as-code-repo-hygiene.md`, `container-host-tuning.md`, `reverse-proxy-and-tls.md`, `ssh-hardening-reference.md`, `mesh-vpn-remote-access.md`, `log-management-reference.md`, `capacity-planning-guide.md`.

Cheatsheets: SSH, DNS, firewall (including the Docker bypass), systemd, cron and timers, rsync, TLS, git, ZFS, LVM, text processing, database CLIs, and Compose hardening. `docs/README.md` indexes everything by task.

## sysadmin-windows

https://github.com/arlytrenck/sysadmin-windows

The Windows Server counterpart to `sysadmin-linux`: 27 PowerShell scripts and 33 docs, checked with PSScriptAnalyzer in CI. Every script carries comment-based help (`Get-Help .\Name.ps1 -Full`), and anything that changes system state supports `-WhatIf`.

It solves the same reuse problem on the Windows side, plus the identity and directory work that a Windows estate carries.

Read the script, run `Get-Help` on it, then run with `-WhatIf` before you let it change anything.

### Problem to script (Windows)

| Problem | Script |
|---------|--------|
| Who is a local admin | `Local-Admin-Audit.ps1` |
| Broader security sweep | `Security-Audit.ps1` |
| Listening ports versus an expectation | `Listening-Ports-Audit.ps1` |
| Disk encryption status | `BitLocker-Status-Audit.ps1` |
| Antivirus and protection state | `Defender-Status-Check.ps1` |
| Backups: rotate and verify | `Backup-Rotate.ps1`, `Backup-Verify.ps1` |
| Certificate expiry | `Cert-Expiry-Check.ps1` |
| Configuration drift and snapshots | `Compare-Config-Drift.ps1`, `Export-Config-Snapshot.ps1` |
| Scheduled tasks nobody remembers | `Scheduled-Task-Audit.ps1` |
| Event log anomalies | `Event-Log-Anomaly-Scan.ps1` |
| Pending reboot, time sync, memory pressure | `Pending-Reboot-Check.ps1`, `Time-Sync-Check.ps1`, `Memory-Pressure-Check.ps1` |
| Account lifecycle | `User-Mgmt.ps1` |
| Patching | `Windows-Update.ps1` |
| Hyper-V configuration export | `Export-HyperV-Config.ps1` |
| Physical disk health and reliability counters | `Disk-Health-Check.ps1` |
| Free space per drive and the largest folders | `Disk-Usage-Report.ps1` |
| Snapshot the active Windows Firewall rules | `Firewall-Rules-Dump.ps1` |
| First-pass network sweep: adapters, routing, DNS, gateway, ports | `Network-Diagnostics.ps1` |
| Installed software, diffed against a baseline | `Package-Inventory.ps1` |
| Recent logons, failed logons, lockouts | `User-Activity-Report.ps1` |
| Processes over a CPU or memory threshold (`-Kill` stops them) | `Process-Watchdog.ps1` |
| Are these services running, optionally restarting them | `Service-Health-Check.ps1` |
| Trim old event log entries and `.log` files | `Log-Cleanup.ps1` |

### Docs worth knowing (Windows)

`active-directory-reference.md`, `group-policy-reference.md`, `dns-dhcp-reference.md`, `recovery-access-and-directory-services-runbook.md`, `certificate-management-reference.md`, `endpoint-protection-guide.md`, `hyper-v-cheatsheet.md`, `powershell-cheatsheet.md`, `powershell-remoting-eventlog-reference.md`, `windows-server-bootstrap-checklist.md`, plus the same runbook and template set as the Linux repo (incident response, disk full, secret rotation, backup DR testing, change management, postmortem).

Also: `windows-in-the-homelab.md`, `database-backup-restore-guide.md`, `capacity-planning-guide.md`, and cheatsheets for robocopy, scheduled tasks, Windows Firewall, networking, and storage.

## homelab-public

https://github.com/arlytrenck/homelab-public

A sanitized public mirror of the Docker Compose infrastructure-as-code behind Arly's homelab: about 35 containers across 9 Compose projects on one VM, run like production. Domains, LAN addresses, and emails are replaced with placeholders. The structure, the hardening conventions, and the Prometheus alert rules are real.

It solves "what does a hardened, monitored, self-hosted stack look like end to end". It covers a reverse proxy with forward-auth SSO, a Prometheus, Alertmanager and Gotify alert path, encrypted layered backups with a monthly restore drill, and Renovate-driven image updates.

Do not copy the compose files directly. Start at `docs/getting-started.md`, then read `docs/lessons-learned.md`, which lists every real mistake behind the conventions.

Key docs:

- `docs/hardening-conventions.md`: the baseline flags, port publishing, updates policy, scoped self-healing.
- `docs/monitoring-and-alerting.md`: how a metric becomes a phone notification.
- `docs/backup-strategy.md`: what is protected, how restores are verified, and the gaps it does not cover.
- `docs/renovate.md`: image updates as reviewed pull requests.
- `docs/runbooks/`: `add-a-service.md`, `add-a-vhost.md`, `rotate-a-secret.md`.
- `tools/`: `check-compose.sh`, `gen-env-examples.sh`, `notify.sh`, `weekly-health-digest.sh`, `export-n8n-workflows.sh`, `github-ci-watch.sh` (a Gotify alert only when the latest GitHub Actions run on a listed repo is red), `push-github-repos.sh` (commit-drift check and push for a set of repos, on a schedule), `seerr-pending-reminder.sh` (a Gotify nag when Seerr or Overseerr requests sit pending).

## trenck.net

https://trenck.net

Arly's site and blog. Posts run about 500 to 1000 words and come in two kinds: field notes from something that happened on the real homelab, and stated opinions. RSS is at https://trenck.net/blog/feed.xml. Other useful pages: `/homelab/`, `/projects/`, `/resume/`, `/certifications/`.

Use it as the primary evidence source for `OPINIONS.md`, and for how Arly writes.

## arlytrenck (profile)

https://github.com/arlytrenck/arlytrenck

The GitHub profile README: bio, focus areas, certifications, and links. Tool areas listed there: Windows and Linux administration, Entra ID and Okta SSO, WireGuard and Tailscale, Cloudflare, EDR/XDR, Ansible, Docker, Proxmox VE and VMware, Git, PowerShell and Bash, Prometheus and Grafana.

## Notes

- `sysadmin-linux` links to a `sysadmin-macos` companion. It is not public, so do not point users at it.
- Where a question needs a script that is not here, do not pretend one exists. Say so.
