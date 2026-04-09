#!/bin/bash
# ============================================================
# Operation ShadowGrid — M1: nova-web Setup
# Challenge: LFI + Apache Log Poisoning → RCE
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[*] Setting up M1 - nova-web (LFI Challenge)"

# ---------- Install dependencies ----------
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 php libapache2-mod-php php-common nmap curl 2>/dev/null

# ---------- Deploy web application ----------
cp -r "$SCRIPT_DIR/webroot/." /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Remove default index.html if exists
rm -f /var/www/html/index.html

# ---------- Generate unique flag ----------
FLAG="FLAG{$(openssl rand -hex 8)_lfi_initial_access}"
mkdir -p /var/www/html/secret
echo "$FLAG" > /var/www/html/secret/flag1.txt
chmod 644 /var/www/html/secret/flag1.txt

cat > /var/www/html/secret/hint.txt << 'EOF'
[Internal Note - NovaTech IT Operations]
Nice find. Keep moving.
Hint: An FTP file-sharing server is running on the internal DMZ segment.
      Anonymous access was "temporarily" enabled during a migration that never finished.
      Port 21 — scan the 11.0.0.0/8 network.
EOF

# ---------- Apache config with world-readable custom log ----------
cat > /etc/apache2/sites-available/000-default.conf << 'APACHECONF'
<VirtualHost *:80>
    ServerName nova-web
    DocumentRoot /var/www/html
    CustomLog /var/log/novatech_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/error.log
    <Directory /var/www/html>
        AllowOverride All
        Options Indexes FollowSymLinks
        Require all granted
    </Directory>
    <Directory /var/www/html/secret>
        Require all denied
    </Directory>
</VirtualHost>
APACHECONF

# Create world-readable log file (required for log poisoning)
touch /var/log/novatech_access.log
chmod 644 /var/log/novatech_access.log
chown www-data:adm /var/log/novatech_access.log

# Logrotate config
cat > /etc/logrotate.d/novatech << 'LOGROTATE'
/var/log/novatech_access.log {
    daily
    missingok
    rotate 7
    compress
    create 644 www-data adm
    postrotate
        systemctl reload apache2 > /dev/null 2>&1 || true
    endscript
}
LOGROTATE

# Ensure PHP is enabled
a2enmod php$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;" 2>/dev/null || echo "8.1") 2>/dev/null || true
a2dismod mpm_event 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true

systemctl restart apache2
systemctl enable apache2

# ---------- Record flag for admin ----------
echo "========================================" >> /root/ctf_setup_log.txt
echo "M1 (nova-web) Flag: $FLAG" >> /root/ctf_setup_log.txt
echo "Setup completed: $(date)" >> /root/ctf_setup_log.txt

echo "[✓] M1 setup complete. Flag recorded in /root/ctf_setup_log.txt"
