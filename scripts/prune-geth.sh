#!/bin/bash

# Prunes old Geth state to save disk

echo "Pruning Geth state..."
docker compose exec geth geth db state prune --datadir=/opt/geth --size=110GB
echo "Prune complete."
