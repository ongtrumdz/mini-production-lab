#!/bin/bash
set -euo pipefail
umask 077

BACKUP_DIR="/var/backups/mini-production"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
DB_NAME="mini_production"
RETENTION_DAYS=7

BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.dump"

mkdir -p "$BACKUP_DIR"

echo "Starting back up of $DB_NAME"

if pg_dump -Fc -d "$DB_NAME" > "$BACKUP_FILE";then
    if [ -s "$BACKUP_FILE" ]; then
        echo "Backup successful: $BACKUP_FILE"
    else
        echo "Backup file is empty"
        rm -f "$BACKUP_FILE"
        exit 1
    fi
else
    echo "Backup failed"
    rm -f "$BACKUP_FILE"
    exit 1
fi

RETENTION_MINUTES=$((RETENTION_DAYS * 24 *60))

find "$BACKUP_DIR" \
    -maxdepth 1 \
    -type f \
    -name "${DB_NAME}_*.dump" \
    -mmin +"$RETENTION_MINUTES" \
    -print \
    -delete
