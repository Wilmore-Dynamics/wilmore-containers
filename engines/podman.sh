#!/bin/bash
# Wilmore Containers - Engine: Podman (Daemonless & Rootless)
# Philosophie : Intégration native au système, respect du Firewall.

set -e

GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${GREEN}[*] Préparation de l'environnement Podman...${NC}"

# 1. Installation de Podman et de ses outils de réseau
apt-get update -qq
apt-get install -y -qq podman slirp4netns uidmap > /dev/null

# 2. Configuration du "subuid/subgid" pour le mode Rootless
# Cela permet à ton utilisateur 'ab' de gérer des conteneurs sans être root
TARGET_USER="${SUDO_USER:-$USER}"
if ! grep -q "$TARGET_USER" /etc/subuid; then
    echo -e "${GREEN}[*] Configuration des plages d'UID pour le mode Rootless...${NC}"
    echo "$TARGET_USER:100000:65536" >> /etc/subuid
    echo "$TARGET_USER:100000:65536" >> /etc/subgid
fi

# 3. Optimisation du stockage (VFS ou Overlay)
# Podman est plus performant avec fuse-overlayfs sur Debian
apt-get install -y -qq fuse-overlayfs > /dev/null

# 4. Alias de confort (Optionnel mais recommandé)
if [ -f "/home/$TARGET_USER/.bashrc" ]; then
    if ! grep -q "alias docker=podman" "/home/$TARGET_USER/.bashrc"; then
        echo "alias docker=podman" >> "/home/$TARGET_USER/.bash_aliases"
        chown "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.bash_aliases"
    fi
fi

echo -e "${GREEN}${BOLD}✔ Podman installé avec succès.${NC}"
echo -e "${GREEN}ℹ Conseil : Utilise 'podman run' comme tu utilisais docker.${NC}"