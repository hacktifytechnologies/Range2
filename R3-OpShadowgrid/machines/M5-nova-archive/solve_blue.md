# 🔵 Blue Team — M5: nova-archive Detection Guide

**Challenge:** SUID Binary Path Traversal  
**Log Sources:** auditd, `/var/log/auth.log`, syslog

---

## What to Look For

### 1. SUID Binary Inventory

```bash
find / -perm -4000 -type f 2>/dev/null | sort
```

Compare against a known-good baseline. `safereader` should stand out as a
non-standard SUID binary in `/usr/local/bin`.

### 2. Process Execution with Anomalous Arguments (auditd)

Deploy this rule:
```bash
auditctl -a always,exit -F path=/usr/local/bin/safereader -F perm=x -k suid_safereader
```

Then watch:
```bash
ausearch -k suid_safereader | grep -E "\.\./|etc/shadow|root/"
```

Look for arguments containing `../` (traversal) or paths outside `/opt/archive`.

### 3. File Access by Root Process with User Real UID

Auditd will show: `uid=<archivist_uid> euid=0` when safereader is invoked.
A root-effective process reading `/root/flag5.txt` on behalf of a non-root user is
a strong SUID abuse indicator.

### 4. /etc/shadow or /root Access

```bash
ausearch --start today -f /root/flag5.txt
ausearch --start today -f /etc/shadow
```

---

## Remediation

- Remove SUID bit if not essential: `chmod -s /usr/local/bin/safereader`
- Fix the validation logic: use `realpath()` to resolve the canonical path first, 
  then check with `strncmp()`:
  ```c
  char resolved[PATH_MAX];
  realpath(path, resolved);
  if (strncmp(resolved, APPROVED_DIR, strlen(APPROVED_DIR)) != 0) { // deny }
  ```
- Follow least privilege: run the tool as a dedicated low-privilege service account
- Conduct regular SUID binary audits across the fleet
