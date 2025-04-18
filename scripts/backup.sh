#!/bin/bash

# Backs up the data directory while the node is stopped

BACKUP_NAME="backup_$(date +%F_%H-%M-%S).tar.gz"

echo "Stopping Ethereum node..."
docker compose down

echo "Creating backup: $BACKUP_NAME"
tar -czvf $BACKUP_NAME data/

echo "Restarting Ethereum node..."
docker compose up -d

echo "Backup complete. Saved as $BACKUP_NAME"
