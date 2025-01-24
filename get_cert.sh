#!/bin/bash

docker compose -f docker-compose.yml run --rm certbot certonly \
    --webroot --webroot-path=/var/www/certbot \
    --email adimas@gmail.com --agree-tos --no-eff-email \
    -d afanasjev.asuscomm.com