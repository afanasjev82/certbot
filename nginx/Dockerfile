FROM nginx:latest

# Install necessary tools
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy configuration templates
COPY conf.d/initial.conf.template /etc/nginx/conf.d/initial.conf.template
COPY conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]