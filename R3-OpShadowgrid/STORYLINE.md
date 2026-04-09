# 📖 Operation ShadowGrid — Storyline

## Background

NovaTech Industries is a mid-sized technology firm operating a hybrid internal network.
Their Security Operations team (blue) has received a threat intel alert that an Advanced
Persistent Threat (APT) group — codenamed **SHADOWGRID** — may have already breached
their external web portal.

The range simulates a realistic lateral movement chain from the public internet all the
way to the sensitive document archive deep inside their private subnet.

---

## Challenge 1 — "First Crack" (M1: nova-web)

**Synopsis:**  
NovaTech's developer recently deployed an internal employee portal using PHP. In a rush
to meet the deadline, they left a dynamic file-inclusion feature exposed via the URL
parameter `?page=`. Additionally, Apache logs are world-readable, enabling a classic
log-poisoning RCE chain.

**Red Team Objective:** Exploit the LFI vulnerability to achieve Remote Code Execution
and read the flag from the secret directory.

**Blue Team Focus:** Apache access logs will show unusual `?page=` parameter values
(directory traversal strings, PHP wrapper usage, /var/log paths) and a crafted
User-Agent containing PHP code. Correlate `access.log` timestamps with shell activity.

---

## Challenge 2 — "Open Door" (M2: nova-ftpvault)

**Synopsis:**  
An internal FTP server was set up for "temporary" file sharing by the IT team.
Anonymous access was never disabled after the initial setup. A handover document left
on the share by a departing employee contains SSH credentials for the next internal host.

**Red Team Objective:** Connect to the FTP server anonymously, retrieve the credentials
file, and obtain the challenge flag.

**Blue Team Focus:** vsftpd logs (`/var/log/vsftpd.log`) will show anonymous logins.
Monitor for directory listings and file downloads of sensitive files. Baseline: legitimate
FTP users should always authenticate with named accounts.

---

## Challenge 3 — "Broken Trust" (M3: nova-gateway)

**Synopsis:**  
The gateway server has a misconfigured sudo rule allowing the `devops` user to run
`/usr/bin/vim` as root without a password — a legacy rule from when devops needed to
edit configuration files. This is a well-known GTFOBin privilege escalation path.

**Red Team Objective:** Log in as `devops`, abuse the sudo vim permission to spawn a
root shell, and read the flag from `/root/`.

**Blue Team Focus:** `auth.log` will show `sudo` invocation for vim by the `devops`
user. A vim process spawning `/bin/bash` as root is highly anomalous. Look for
`COMMAND=/usr/bin/vim` in sudo logs followed by shell process creation under the
root UID.

---

## Challenge 4 — "Tick Tock" (M4: nova-scheduler)

**Synopsis:**  
A routine maintenance cron job runs every minute as root. The shell script it executes
(`/opt/scripts/maintenance.sh`) was left world-writable during a debug session and was
never locked down. A patient attacker need only append a single command to hijack
root execution.

**Red Team Objective:** Modify the world-writable cron script to copy bash with the SUID
bit set, wait one minute for root cron execution, and then use the SUID bash to escalate.

**Blue Team Focus:** Cron execution logs in `/var/log/syslog` will show the job firing.
Auditd rules (if deployed) would catch writes to `/opt/scripts/maintenance.sh`.
A new SUID binary appearing in `/tmp` is a critical indicator. Monitor for
unexpected `chmod +s` events on non-standard binaries.

---

## Challenge 5 — "The Last Layer" (M5: nova-archive)

**Synopsis:**  
The archive server hosts a custom internal tool called `safereader` — a SUID root binary
intended to read documents only from `/opt/archive/`. However, the path validation logic
uses a flawed `strstr()` check: it verifies the string `/opt/archive` exists in the path,
but doesn't prevent traversal. An attacker who knows this can read any file owned by root.

**Red Team Objective:** Use `safereader` with a path traversal payload to read the root
flag from `/root/flag5.txt`.

**Blue Team Focus:** Process execution logs will show `safereader` being called with
unusual paths containing `../`. The effective UID of the process will be 0 (root) while
the real UID is a normal user. This is a strong indicator of SUID abuse. Deploy
`auditd` rules monitoring execve calls on SUID binaries for anomalous arguments.

---

## Narrative Arc

```
[Internet] ──→ nova-web (M1)
                   │  LFI + RCE
                   ▼
             nova-ftpvault (M2)  ←── same DMZ subnet
                   │  anon FTP creds
                   ▼
             nova-gateway (M3)  ←── pivot: DMZ → Private
                   │  sudo vim → root → SSH key/creds
                   ▼
             nova-scheduler (M4)  ←── private subnet
                   │  cron hijack → root → creds
                   ▼
             nova-archive (M5)  ←── deep private subnet
                        SUID traversal → root flag
```
