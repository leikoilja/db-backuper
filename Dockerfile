# Start from a base image that includes bash and the PostgreSQL client
FROM postgres:16

# Install cron
RUN apt-get update && \
    apt-get install -y cron && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the backup scripts into the container
COPY backup_pg_databases.sh /app/backup_pg_databases.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Use an entrypoint script to start the container processes
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Use the entrypoint script to execute at container runtime
CMD ["/app/entrypoint.sh"]