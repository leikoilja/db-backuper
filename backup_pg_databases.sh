#!/bin/bash

# PostgreSQL Database Backup Script
# Format of URLs in the list should be: postgresql://username:password@hostname:port/database_name

# BASE_BACKUP_DIR="/var/services/homes/leikoilja/Backups/databases"
# URL_LIST="/var/services/homes/leikoilja/Development/scripts/db_backups/pg_db_urls.sh"

# DEV
BASE_BACKUP_DIR="/app/pg_dumps"  # TODO: change to an absolute path on Synology
URL_LIST="/app/pg_db_urls.sh"

DAYS_TO_KEEP=7
TIMESTAMP=$(date +"%Y%m%d%H%M")
LOG_FILE="./backup.log"
EXIT_STATUS=0

# Create base backup directory if it doesn't exist
mkdir -p "$BASE_BACKUP_DIR"

# Check if URL list exists
if [ ! -f "$URL_LIST" ]; then
    echo "Database URL list file not found!" | tee -a "$LOG_FILE"
    exit 1
fi

# Function to extract database name or replace 'postgres' with the username
get_db_name() {
    local db_url="$1"
    local db_name=$(echo "$db_url" | sed -E 's,.*/([^/?]+).*$,\1,')

    if [[ "$db_name" == "postgres" ]]; then
        db_name=$(echo "$db_url" | sed -E 's,^.+://([^:]+):.*$,\1,')
    fi

    echo "$db_name"
}

# Function to cleanup old backups
cleanup_old_backups() {
    local db_name=$1
    local dir_path="$BASE_BACKUP_DIR/$db_name"
    find "$dir_path" -name "${db_name}_*.sql.gz" -mtime +"$DAYS_TO_KEEP" -exec rm -v {} \; | tee -a "$LOG_FILE"
}

# Read each URL from the list and perform the backup
while IFS= read -r db_url || [ -n "$db_url" ]; do
    # Skip empty lines and comments
    [[ -z "$db_url" || "$db_url" =~ ^#.*$ ]] && continue

    # Extract database name or username if database name is 'postgres'
    db_name=$(get_db_name "$db_url")

    echo "Starting backup of $db_name" | tee -a "$LOG_FILE"

    # Create a directory for each database if it doesn't exist
    db_backup_dir="$BASE_BACKUP_DIR/$db_name"
    mkdir -p "$db_backup_dir"

    # Temporary output file
    temp_output=$(mktemp)

    # Final output path
    final_output="$db_backup_dir/${db_name}_${TIMESTAMP}.sql.gz"

    # Export password variable (optional and depends on your security preference)
    export PGPASSWORD=$(echo "$db_url" | sed -E 's,^.+://[^:]+:([^@]+)@.*$, \1,')

    # Record the start time
    start_time=$(date +%s)

    # Dump the database to a temporary file
    if pg_dump "$db_url" -Fp > "$temp_output"; then
        # Compress the dump if successful
        gzip < "$temp_output" > "$final_output"

        # Record the end time
        end_time=$(date +%s)
        duration=$((end_time - start_time))

        echo "Backup completed successfully for $db_name to $final_output" | tee -a "$LOG_FILE"
        echo "Backup for $db_name took $duration seconds" | tee -a "$LOG_FILE"

        # Cleanup old backups
        cleanup_old_backups "$db_name"
    else
        echo "[ERROR] Backup failed for $db_name" | tee -a "$LOG_FILE"
        EXIT_STATUS=1
        # No output file will be created
    fi

    # Clean up the temporary file
    rm -f "$temp_output"

    # Unset password variable for security
    unset PGPASSWORD

done < "$URL_LIST"

echo "Database backups completed at $(date)" | tee -a "$LOG_FILE"

# Exit with error if any backup failed
exit $EXIT_STATUS