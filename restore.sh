#!/bin/bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOG_DIR="$PROJECT_DIR/backups/logs"
LOG_FILE="$LOG_DIR/restore.log"

CONTAINER_NAME="clientorahq-db"
DB_USER="appuser"
TEST_DB="appdb_restore_test"

BACKUP_FILE="${1:-}"

mkdir -p "$LOG_DIR"

if [[ -z "$BACKUP_FILE" || ! -f "$BACKUP_FILE" ]]; then
    echo "Usage: ./restore.sh backups/backup-file.sql.gz"
    exit 1
fi

echo "[$(date)] Starting restore test..." >> "$LOG_FILE"

# Check database container
docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER"

# Recreate only the dedicated test database
docker exec "$CONTAINER_NAME" dropdb \
    -U "$DB_USER" --if-exists "$TEST_DB"

docker exec "$CONTAINER_NAME" createdb \
    -U "$DB_USER" "$TEST_DB"

# Restore backup
if gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" \
    psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$TEST_DB"; then

    echo "[$(date)] SUCCESS: Restore completed in $TEST_DB" >> "$LOG_FILE"
    echo "Restore successful!"

else
    echo "[$(date)] ERROR: Restore failed." >> "$LOG_FILE"
    exit 1
fi
