#!/bin/bash

# Log file path
LOG_FILE="/var/log/script_execution.log"

# Function to check the exit status of the last executed command
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
> $LOG_FILE

# Update package lists
echo "Running apt update..." | tee -a $LOG_FILE
sudo apt -y update
check_exit_status "apt update"

# Upgrade installed packages
echo "Running apt upgrade..." | tee -a $LOG_FILE
sudo apt -y upgrade
check_exit_status "apt upgrade"

# Clone the GitHub repository
echo "Cloning GitHub repository..." | tee -a $LOG_FILE
sudo git clone -b test https://github.com/Iqrazamir1/WordPressPractise.git /root/WordPressPractise
check_exit_status "git clone"

# Change permissions of the cloned repository
echo "Changing permissions of the cloned repository..." | tee -a $LOG_FILE
sudo chmod -R 755 /root/WordPressPractise
check_exit_status "chmod"

# Run the setup script
log "Running lemp-setup.sh script..."

sudo apt update -y
sudo apt upgrade -y
sudo touch /root/testing.txt
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx 
sudo systemctl status nginx > /root/testing.txt
sudo apt -y install php-fpm php php-cli php-common php-imap  php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /root/testing.txt

sudo mv /root/WordPressPractise/configs/nginx.conf /etc/nginx/conf.d/nginx.conf

# my_domain=REPLACE_DOMAIN
# elastic_ip=REPLACE_MY_ELASTIC_IP

# CF_API=REPLACE_CF_API
# CF_ZONE_ID=REPLACE_CF_ZONE_ID

# Create A record
# log "Creating A record..."
# curl --request POST \
#  --url https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records \
#  --header 'Content-Type: application/json' \
#  --header "Authorization: Bearer $CF_API" \
#  --data '{
#  "content": "'"$elastic_ip"'",
# "name": "'"$my_domain"'",
#  "proxied": true,
#  "type": "A",
#  "comment": "Automatically adding A record",
#  "tags": [],
#  "ttl": 3600
# }'

# Update nginx configuration file
sed -i "s/SERVERNAME/$dns_record/g" /etc/nginx/conf.d/nginx.conf
nginx -t && systemctl reload nginx 

# Update package list and install Certbot and Certbot Nginx plugin
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y certbot
sudo apt install -y python3-certbot-nginx

# # Define your email
# EMAIL=REPLACE_EMAIL
# DOMAIN=REPLACE_DOMAIN

# Define your email
EMAIL="zamiriqra0@outlook.com"
DOMAIN="certbot.paints-4-you.com"

sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN

# Nginx unit test that will reload Nginx to apply changes ONLY if the test is successful
sudo nginx -t && systemctl reload nginx

# Install WordPress
sudo apt -y install unzip && sudo apt -y install zip
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip 
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip
sudo mv /var/www/wordpress /var/www/html

sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/wordpress

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php
