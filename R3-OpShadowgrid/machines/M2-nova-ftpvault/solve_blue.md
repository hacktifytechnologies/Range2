# 🔵 Blue Team — M2: nova-ftpvault Detection Guide

**Challenge:** Anonymous FTP  
**Log Source:** `/var/log/vsftpd.log`

---

## What to Look For

### 1. Anonymous Login Events

```bash
grep "ANONYMOUS LOGIN" /var/log/vsftpd.log
grep "anonymous" /var/log/vsftpd.log
```

Every anonymous login will show source IP, timestamp, and authenticated user ("anonymous").

### 2. File Download Events

```bash
grep "DOWNLOAD" /var/log/vsftpd.log
grep "staff_handover.txt\|flag" /var/log/vsftpd.log
```

A download of `staff_handover.txt` is the critical indicator — this file contains credentials.

### 3. Correlate with M3 Auth Events

After FTP download, check M3's auth.log for SSH login from same source IP within a short window.

---

## Remediation

- Set `anonymous_enable=NO` in `/etc/vsftpd.conf` immediately
- Never store credentials in plaintext on shared file systems
- Rotate all credentials exposed via FTP immediately
- Use named FTP accounts with logging enabled
- Consider replacing FTP with SFTP (SSH-based)
