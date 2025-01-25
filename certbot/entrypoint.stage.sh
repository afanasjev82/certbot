#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e
echo "Starting Certbot for DOMAIN=${CERTBOT_DOMAIN}"

# Obtain the initial certificate using the staging environment
certbot certonly --webroot --webroot-path=/var/www/certbot \
  --email "${CERTBOT_EMAIL}" --agree-tos --no-eff-email \
  -d "${CERTBOT_DOMAIN}" --non-interactive --staging

# Start the renewal loop
while :; do
  echo "Renewing SSL certificates..."
  certbot renew \
    --webroot \
    --webroot-path=/var/www/certbot \
    --staging
    
  echo "Renewal process completed."
  if [ $? -eq 0 ]; then
    # Reload the Nginx container to apply the renewed certificate
    docker exec nginx nginx -s reload
    echo "Nginx configuration reloaded."
  fi
  
  # Wait for 1 minute before the next renewal attempt
  sleep 1m
done