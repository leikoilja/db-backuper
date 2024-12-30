#!/bin/bash

# Ensure environment variables are set
: "${CRON_SCHEDULE:?Need to set CRON_SCHEDULE}"
: "${DAYS_TO_KEEP:?Need to set DAYS_TO_KEEP}"

# Define the cron job using the environment variable
CRONTAB_LINE="$CRON_SCHEDULE /app/backup_pg_databases.sh >> /var/log/cron.log 2>&1"

# Write out the current crontab and append the new job
(crontab -l 2>/dev/null; echo "$CRONTAB_LINE") | crontab -

# Start cron service
cron

# Tail the cron log to keep the container running
tail -f /var/log/cron.log