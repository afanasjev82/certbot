#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e
echo "Starting Certbot for DOMAIN=${CERTBOT_DOMAIN}"

# Obtain the initial certificate
certbot certonly --webroot --webroot-path=/var/www/certbot \
  --email "${CERTBOT_EMAIL}" --agree-tos --no-eff-email \
  -d "${CERTBOT_DOMAIN}" --non-interactive

# Start the renewal loop
while :; do

  # Renew the SSL certificates
  certbot renew \
    --webroot \
    --webroot-path=/var/www/certbot

  if [ $? -eq 0 ]; then
    # Reload the Nginx container to apply the renewed certificate
    docker exec nginx nginx -s reload
  fi
  # Wait for 12 hours before the next renewal attempt
  sleep 12h
done