# Start from a base image that includes bash and the PostgreSQL client
FROM postgres:16

# Install cron
RUN apt-get update && \
    apt-get install -y cron && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy your backup script into the container
COPY backup_pg_databases.sh /app/backup_pg_databases.sh

# Copy your database URL file
COPY pg_db_urls.sh /app/pg_db_urls.sh

# Ensure the script is executable
RUN chmod +x /app/backup_pg_databases.sh

# Add crontab file and run the command
COPY crontab /etc/cron.d/pg_backup_cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/pg_backup_cron

# Apply the cron job
RUN crontab /etc/cron.d/pg_backup_cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Start the cron services, and log output
CMD cron && tail -f /var/log/cron.log