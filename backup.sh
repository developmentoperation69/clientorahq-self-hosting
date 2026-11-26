#!/bin/bash

set -euo pipefail

export PATH=/usr/local/bin:/usr/bin:/bin

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup settings
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$BACKUP_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"

CONTAINER_NAME="clientorahq-db"
DB_NAME="appdb"
DB_USER="appuser"

# Create directories
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Backup filename
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

echo "[$(date)] Starting database backup..." >> "$LOG_FILE"

# Check PostgreSQL
if ! docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
    echo "[$(date)] ERROR: Database is not available." >> "$LOG_FILE"
    exit 1
fi

# Create compressed backup
if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    echo "[$(date)] SUCCESS: Backup created: $BACKUP_FILE" >> "$LOG_FILE"
else
    rm -f "$BACKUP_FILE"
    echo "[$(date)] ERROR: Backup failed." >> "$LOG_FILE"
    exit 1
fi

echo "[$(date)] Backup completed successfully." >> "$LOG_FILE"


# Delete backups older than 7 days
echo "[$(date)] Checking old backups..." >> "$LOG_FILE"

find "$BACKUP_DIR" -maxdepth 1 \
-type f -name 'appdb_*.sql.gz' \
-mmin +10080 -print -delete >> "$LOG_FILE" 2>&1

echo "[$(date)] Backup retention completed." >> "$LOG_FILE"
