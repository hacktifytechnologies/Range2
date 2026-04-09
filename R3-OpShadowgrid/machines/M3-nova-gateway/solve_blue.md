# 🔵 Blue Team — M3: nova-gateway Detection Guide

**Challenge:** Sudo Misconfiguration — vim GTFOBin  
**Log Sources:** `/var/log/auth.log`, `/var/log/syslog`

---

## What to Look For

### 1. Sudo Events for vim

```bash
grep "sudo.*vim" /var/log/auth.log
grep "COMMAND.*vim" /var/log/auth.log
```

Key pattern:
```
devops : TTY=pts/0 ; PWD=/home/devops ; USER=root ; COMMAND=/usr/bin/vim
```

### 2. Shell Spawned from vim as Root

If auditd is running:
```bash
ausearch -c "bash" --start today | grep "euid=0"
```

A bash shell with effective UID 0 (root) spawned as child of a `vim` process is the
definitive indicator.

### 3. Subsequent Root Activity

```bash
grep "root" /var/log/auth.log | grep -v "sudo\|cron\|sshd"
```

Look for root shell commands executed after the vim escalation.

---

## Remediation

- Remove the NOPASSWD sudo rule: `rm /etc/sudoers.d/novatech-devops`
- If vim is needed, restrict it to specific files:
  `devops ALL=(ALL) NOPASSWD: /usr/bin/vim /etc/nginx/nginx.conf`
  (Even this is dangerous — GTFOBins works on file-restricted vim too)
- Better: Use `sudoedit` for config file editing: `devops ALL=(ALL) sudoedit /etc/specific.conf`
- Run `sudo -l` audit across all systems regularly
