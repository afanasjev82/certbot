FROM certbot/certbot:latest

# Install Docker CLI to interact with Docker daemon
RUN apk update && apk add --no-cache docker-cli

# Copy the custom entrypoint script into the image
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]