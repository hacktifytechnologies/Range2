# 🌐 Network Diagram — Operation ShadowGrid

```
                    ┌─────────────────────────────┐
  [Player VPN]      │   Floating IP (172.24.4.0/24)│
  via WireGuard ───►│   assigned to M1 only        │
                    └──────────────┬──────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │  v-Pub-subnet  203.0.0.0/8   │
                    │                              │
                    │  ┌────────────────────┐      │
                    │  │  M1: nova-web      │      │
                    │  │  Apache2 + PHP     │      │
                    │  │  (Pub + DMZ NIC)   │      │
                    │  └────────┬───────────┘      │
                    └───────────┼──────────────────┘
                                │
                    ┌───────────▼──────────────────┐
                    │  v-DMZ-subnet  11.0.0.0/8    │
                    │                              │
                    │  ┌──────────────────┐        │
                    │  │ M2: nova-ftpvault│        │
                    │  │ vsftpd           │        │
                    │  └──────────────────┘        │
                    │                              │
                    │  ┌──────────────────┐        │
                    │  │ M3: nova-gateway  │        │
                    │  │ SSH + dual-homed  │        │
                    │  │ (DMZ + Priv NIC) │        │
                    │  └────────┬─────────┘        │
                    └───────────┼──────────────────┘
                                │
                    ┌───────────▼──────────────────┐
                    │  v-Priv-subnet 195.0.0.0/8   │
                    │                              │
                    │  ┌──────────────────┐        │
                    │  │ M4: nova-scheduler│        │
                    │  │ cron + SSH        │        │
                    │  └──────────────────┘        │
                    │                              │
                    │  ┌──────────────────┐        │
                    │  │ M5: nova-archive  │        │
                    │  │ SUID binary + SSH │        │
                    │  └──────────────────┘        │
                    └──────────────────────────────┘
```

## Port Summary

| Machine | Hostname         | Open Ports              |
|---------|------------------|-------------------------|
| M1      | nova-web         | 80/tcp (HTTP)           |
| M2      | nova-ftpvault    | 21/tcp (FTP)            |
| M3      | nova-gateway     | 22/tcp (SSH)            |
| M4      | nova-scheduler   | 22/tcp (SSH)            |
| M5      | nova-archive     | 22/tcp (SSH)            |

## Discovery Notes (No Static IPs)

- M1 is the only machine directly accessible from the floating IP.
- From M1's shell, scan the DMZ subnet (`11.0.0.0/8`) for open ports:
  `nmap -sV --open -p 21,22,80 11.0.0.0/8 --min-rate 1000`
- M3 bridges DMZ → Private. From M3's root shell, scan `195.0.0.0/8`.
- All machines use DHCP — IPs will differ per team per provisioning.
