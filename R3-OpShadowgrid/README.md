# 🛡️ Operation ShadowGrid — Cyber Range

> **Theme:** NovaTech Industries' internal network has been targeted.  
> **Format:** Linear, interconnected, 5 machines, Red & Blue perspectives.  
> **Platform:** Ubuntu 22.04 (Jammy), OpenStack provisioned.  
> **No Docker. No SQL Injection.**

---

## Directory Structure

```
operation-shadowgrid/
├── README.md
├── STORYLINE.md
├── NETWORK_DIAGRAM.md
├── machines/
│   ├── M1-nova-web/          ← LFI + Log Poisoning
│   ├── M2-nova-ftpvault/     ← Anonymous FTP / Credential Exposure
│   ├── M3-nova-gateway/      ← Sudo Misconfiguration (GTFOBin)
│   ├── M4-nova-scheduler/    ← Cron Job Hijacking
│   └── M5-nova-archive/      ← SUID Binary Path Traversal
└── ttps/
    ├── blue/                 ← 5 Attack TTPs (Caldera, generates logs)
    └── red/                  ← 5 Setup TTPs (Caldera, configures vulns)
```

---

## Quick Setup (Per Machine)

```bash
# On each Ubuntu 22.04 VM:
git clone https://github.com/<your-repo>/operation-shadowgrid.git /opt/ctf
cd /opt/ctf
sudo bash machines/M1-nova-web/setup.sh        # Run on M1
sudo bash machines/M2-nova-ftpvault/setup.sh   # Run on M2
sudo bash machines/M3-nova-gateway/setup.sh    # Run on M3
sudo bash machines/M4-nova-scheduler/setup.sh  # Run on M4
sudo bash machines/M5-nova-archive/setup.sh    # Run on M5
```

After running each setup.sh, retrieve the flag from `/root/ctf_setup_log.txt` for your CTF platform.

---

## OpenStack Network Assignment

| Machine       | Hostname         | Networks                           |
|---------------|------------------|------------------------------------|
| M1            | nova-web         | v-Pub-subnet + v-DMZ-subnet        |
| M2            | nova-ftpvault    | v-DMZ-subnet                       |
| M3            | nova-gateway     | v-DMZ-subnet + v-Priv-subnet       |
| M4            | nova-scheduler   | v-Priv-subnet                      |
| M5            | nova-archive     | v-Priv-subnet                      |

Players access the range via the Floating IP assigned to M1.

---

## Credentials Flow (After Solving)

```
M1 (RCE via LFI)  →  Hint: scan DMZ for FTP
        ↓
M2 (anon FTP)     →  staff_handover.txt: devops:N0vaTech@24
        ↓
M3 (SSH + sudo)   →  /root/secrets.txt: backup:Backups3cure  (M4)
        ↓
M4 (cron hijack)  →  /root/secrets.txt: archivist:Arch1v1st99 (M5)
        ↓
M5 (SUID)         →  Final Flag
```

---

## TTP Usage

- **Blue TTPs** — Load into Caldera's Atomic plugin on each machine. Running them simulates attacker actions and generates logs for blue teamers to investigate.
- **Red TTPs** — Load into Caldera and run on a fresh machine to configure the vulnerable environment (alternative to running setup.sh manually).
