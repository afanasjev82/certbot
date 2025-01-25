#!/bin/sh
# filepath: /path/to/script.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Define colors
GREEN="\033[0;32m"
RED="\033[0;31m"
ORANGE="\033[0;33m"
NC="\033[0m" # No Color

## Functions ####################################################################################################################

# Logging functions
log_info() {
	echo "${GREEN}$1${NC}"
}

log_warning() {
	echo "${ORANGE}$1${NC}"
}

log_error() {
	echo "${RED}$1${NC}"
}

log_info "Starting Nginx with DOMAIN=${DOMAIN}"

if [ -z "${DOMAIN}" ]; then
	log_error "DOMAIN environment variable is not set."
	exit 1
fi

# Function to check if SSL certificates exist
check_certificates() {
	if [ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" ]; then
	return 0
	else
	return 1
	fi
}

# Function to configure Nginx for HTTPS
configure_nginx_https() {
	log_info "SSL certificates found. Reconfiguring Nginx for HTTPS ..."

	# Reconfigure Nginx to use the default HTTPS configuration
	sed "s/{domain}/${DOMAIN}/g" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

	log_info "Generated Nginx configuration for HTTPS:"
	cat /etc/nginx/conf.d/default.conf
	log_info "\nNginx has been reconfigured for HTTPS."
}

# Function to start Nginx
start_nginx() {
	# Start Nginx in the background
	nginx -g "daemon off;" &
	log_info "\nNginx has been started."
}

# Function to perform initial setup
initial_setup() {
	log_warning "SSL certificates not found. Starting Nginx with HTTP ..."
	log_info "Configuring Nginx for initial certificate fetching ..."
		
	sed "s/{domain}/${DOMAIN}/g" /etc/nginx/conf.d/initial.conf.template > /etc/nginx/conf.d/default.conf
	
	log_info "Generated Nginx configuration for initial setup:"
	cat /etc/nginx/conf.d/default.conf
	
	start_nginx
	
	log_info "Waiting for SSL certificates to be generated ..."
	
	MAX_RETRIES=60       # Maximum number of retries (e.g., 60 retries * 10s = 600s)
	RETRY_INTERVAL=10    # Seconds between retries
	COUNTER=0
	
	# Check if SSL certificates exist
	while ! check_certificates; do
		COUNTER=$((COUNTER + 1))
		if [ "$COUNTER" -gt "$MAX_RETRIES" ]; then
			log_error "Error: SSL certificates not found after $MAX_RETRIES attempts. Exiting."
			kill $!
			exit 1
		fi
		log_info "Certificates not found. Waiting ($COUNTER/$MAX_RETRIES) ..."
		sleep "$RETRY_INTERVAL"
	done

	# Configure Nginx for HTTPS
	configure_nginx_https

	# Reload Nginx with the new configuration
	nginx -s reload
	log_info "Nginx has been reconfigured for HTTPS."
}

## Main script ##################################################################################################################

# Check if SSL certificates exist
if check_certificates; then
	configure_nginx_https
	start_nginx
else
	initial_setup
fi

# Keep the script running to keep the container alive
wait