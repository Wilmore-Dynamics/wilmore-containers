#!/bin/bash
# Wilmore Containers - Tool: Backup System v1.0
# Sauvegarde à chaud des volumes et configurations Rootless.

set -e

GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
BACKUP_DIR="$USER_HOME/backups"
DATE=$(date +%Y-%m-%d_%H%M)

echo -e "${GREEN}[*] Initialisation de la sauvegarde pour : ${BOLD}$TARGET_USER${NC}"

# 1. Création du coffre-fort si inexistant
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    chown "$TARGET_USER:$TARGET_USER" "$BACKUP_DIR"
fi

# 2. Archivage via Podman Unshare
echo -e "${GREEN}[*] Compression des stacks et configurations...${NC}"

sudo -u "$TARGET_USER" podman unshare tar -czf "$BACKUP_DIR/wilmore_backup_$DATE.tar.gz" \
    -C "$USER_HOME" \
    stacks/ \
    .config/containers/systemd/

# 3. Vérification
if [ -f "$BACKUP_DIR/wilmore_backup_$DATE.tar.gz" ]; then
    SIZE=$(du -sh "$BACKUP_DIR/wilmore_backup_$DATE.tar.gz" | cut -f1)
    echo -e "${GREEN}${BOLD}✔ Succès : Sauvegarde créée (${SIZE})${NC}"
    echo -e "Fichier : $BACKUP_DIR/wilmore_backup_$DATE.tar.gz"
else
    echo -e "${RED}Erreur lors de la création de la sauvegarde.${NC}"
    exit 1
fi