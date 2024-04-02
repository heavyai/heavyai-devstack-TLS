#!/bin/bash

CONFIG_FILE="/path/to/your/nginx/config/file"
DOMAIN="yourdomain.com"

# Prepare the lines to insert
SSL_CERT="    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;"
SSL_KEY="    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;"

# Insert the lines after the error_log line
sed -i "/error_log/a \\${SSL_CERT}\n${SSL_KEY}" "$CONFIG_FILE"

echo "Inserted SSL configuration for $DOMAIN into $CONFIG_FILE"
