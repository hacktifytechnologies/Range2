#!/bin/bash
# ============================================================
# Operation ShadowGrid — M3: nova-gateway Setup
# Challenge: Sudo Misconfiguration — vim GTFOBin
# ============================================================
set -e
echo "[*] Setting up M3 - nova-gateway (Sudo Misconfiguration)"

# ---------- Install packages ----------
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server vim nmap 2>/dev/null

# ---------- Create devops user ----------
if ! id "devops" &>/dev/null; then
    useradd -m -s /bin/bash devops
fi
echo "devops:N0vaTech@24" | chpasswd

# ---------- Configure sudo misconfiguration ----------
# Ensure sudoers.d exists
mkdir -p /etc/sudoers.d
cat > /etc/sudoers.d/novatech-devops << 'EOF'
# NovaTech - devops vim access for config editing (ticket #3701)
# TODO: Restrict to specific files (never done)
devops ALL=(ALL) NOPASSWD: /usr/bin/vim
EOF
chmod 440 /etc/sudoers.d/novatech-devops

# ---------- Generate flag ----------
FLAG="FLAG{$(openssl rand -hex 8)_sudo_vim_privesc}"
echo "$FLAG" > /root/flag3.txt
chmod 600 /root/flag3.txt

# Credentials hint for M4
cat > /root/secrets.txt << 'EOF'
[NovaTech Operations - Internal Notes]
M4 nova-scheduler access:
  SSH User: backup
  SSH Pass: Backups3cure
  Purpose: Runs nightly backup scripts
EOF
chmod 600 /root/secrets.txt

# ---------- SSH config ----------
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd

# ---------- Record flag ----------
echo "========================================" >> /root/ctf_setup_log.txt
echo "M3 (nova-gateway) Flag: $FLAG" >> /root/ctf_setup_log.txt
echo "Setup completed: $(date)" >> /root/ctf_setup_log.txt

echo "[✓] M3 setup complete. Flag recorded in /root/ctf_setup_log.txt"
