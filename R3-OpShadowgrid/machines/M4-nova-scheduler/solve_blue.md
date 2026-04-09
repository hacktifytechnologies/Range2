# 🔵 Blue Team — M4: nova-scheduler Detection Guide

**Challenge:** Cron Script Hijacking  
**Log Sources:** `/var/log/syslog`, `/var/log/maintenance.log`, auditd

---

## What to Look For

### 1. Cron Execution (Baseline)

```bash
grep "CRON.*maintenance" /var/log/syslog
```

Normal output: `CRON[xxxx]: (root) CMD (/opt/scripts/maintenance.sh)` every minute.

### 2. World-Writable Cron Script (Configuration Audit)

```bash
find /opt/scripts /etc/cron* /var/spool/cron -writable -not -user root 2>/dev/null
stat /opt/scripts/maintenance.sh
```

The 777 permission on a root-owned cron script is a **critical misconfiguration**.

### 3. Script Content Change

```bash
# Monitor file modification time
stat /opt/scripts/maintenance.sh | grep Modify

# If auditd is deployed, watch for writes:
auditctl -w /opt/scripts/maintenance.sh -p wa -k cron_tamper
ausearch -k cron_tamper
```

### 4. Anomalous SUID Binary in /tmp

```bash
find /tmp -perm /4000 2>/dev/null
```

A SUID binary appearing in `/tmp` is a high-confidence indicator of privilege escalation.

### 5. Root Shell from Unexpected Parent

```bash
# In auditd: bash process with euid=0 and parent being maintenance.sh
ausearch -c "bash" | grep "euid=0"
```

---

## Remediation

- Fix permissions immediately: `chmod 755 /opt/scripts/maintenance.sh`
- Principle of least privilege: cron scripts should not be world-writable
- Regularly audit: `find / -perm -0002 -user root -type f 2>/dev/null`
- Deploy auditd watches on all cron-executed scripts
- Remove SUID binaries from /tmp: `find /tmp -perm /4000 -delete`
