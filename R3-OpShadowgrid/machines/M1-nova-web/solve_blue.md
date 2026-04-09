# 🔵 Blue Team — M1: nova-web Detection Guide

**Challenge:** LFI + Apache Log Poisoning  
**Log Sources:** `/var/log/novatech_access.log`, `/var/log/apache2/error.log`

---

## What to Look For

### 1. LFI Attempts in Access Log

```bash
grep -E "page=(/etc|/var|/proc|php://)" /var/log/novatech_access.log
```

Indicators:
- `?page=/etc/passwd` — direct file read attempt
- `?page=php://filter/...` — PHP wrapper based LFI
- `?page=/var/log/...` — log poisoning setup

### 2. PHP Code in User-Agent

```bash
grep -i "<?php" /var/log/novatech_access.log
grep -i "system\|exec\|passthru\|shell_exec" /var/log/novatech_access.log
```

A User-Agent containing `<?php system($_GET['cmd']); ?>` is the definitive
log poisoning indicator.

### 3. RCE Command Execution

```bash
grep -E "cmd=(id|whoami|cat|ls|bash|nc)" /var/log/novatech_access.log
```

### 4. Timeline Correlation

Build a timeline:
1. First `?page=/var/log/novatech_access.log` request (read probe)
2. Request with malicious User-Agent (injection)
3. Second `?page=/var/log/novatech_access.log&cmd=...` (execution)

### 5. Shell Process from Apache (SIEM / Auditd)

If auditd is deployed:
```bash
ausearch -c "bash" --start today | grep "uid=33"   # uid 33 = www-data
```

---

## Remediation

- Never pass user input directly to `include()` or `require()`
- Use an allowlist for valid page names: `$allowed = ['home','about','news','contact']`
- Restrict Apache log file permissions: `chmod 640 /var/log/novatech_access.log`
- Deploy a WAF rule blocking `../`, `php://`, `/etc/`, `/var/log/` in GET parameters
- Enable PHP's `open_basedir` restriction in `php.ini`
