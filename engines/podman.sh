#!/bin/bash
# Wilmore Containers - Engine: Podman (Daemonless, Rootless & Quadlet Ready)
# Philosophie : Souveraineté totale, isolation noyau et persistance systemd.

set -e

# --- Couleurs Wilmore ---
GREEN='\033[0;32m'
BOLD='\033[1m'
BLUE='\033[0;34m'
NC='\033[0m'

# Identification de l'utilisateur non-root (ab)
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo -e "${BLUE}[*] Initialisation du moteur Podman pour l'utilisateur : ${BOLD}$TARGET_USER${NC}"

# 1. Installation des paquets critiques
# slirp4netns : Pile réseau mode utilisateur
# uidmap : Nécessaire pour le mapping des UID rootless
# fuse-overlayfs : Meilleures performances de stockage sur Debian
echo -e "${GREEN}[*] Installation des binaires et dépendances...${NC}"
apt-get update -qq
apt-get install -y -qq podman slirp4netns uidmap fuse-overlayfs curl dbus-user-session > /dev/null

# 2. Configuration des plages d'identifiants (subuid/subgid)
if ! grep -q "$TARGET_USER" /etc/subuid; then
    echo -e "${GREEN}[*] Configuration des namespaces UID/GID...${NC}"
    # On alloue 65536 IDs pour permettre l'isolation interne des containers
    echo "$TARGET_USER:100000:65536" >> /etc/subuid
    echo "$TARGET_USER:100000:65536" >> /etc/subgid
fi

# 3. Hardening Réseau : Autoriser les ports privilégiés en mode Rootless
# Par défaut, un utilisateur non-root ne peut pas ouvrir le port 80 ou 443.
# On abaisse cette limite à 80 pour permettre le Reverse Proxy sans root.
echo -e "${GREEN}[*] Ajustement des privilèges réseau (sysctl)...${NC}"
cat <<EOF > /etc/sysctl.d/99-podman-rootless.conf
net.ipv4.ip_unprivileged_port_start=80
EOF
sysctl --system > /dev/null

# 4. Activation du mode Linger (Survie du service après déconnexion)
# Indispensable pour que les Quadlets démarrent au boot de la VM.
echo -e "${GREEN}[*] Activation de la persistance utilisateur (Linger)...${NC}"
loginctl enable-linger "$TARGET_USER"

# 5. Préparation de l'arborescence Quadlet & Stacks
echo -e "${GREEN}[*] Création des dossiers de configuration utilisateur...${NC}"
sudo -u "$TARGET_USER" mkdir -p "$USER_HOME/.config/containers/systemd"
sudo -u "$TARGET_USER" mkdir -p "$USER_HOME/stacks"

# 6. Alias de confort (Docker drop-in replacement)
if [ -d "$USER_HOME" ]; then
    BASH_ALIAS="$USER_HOME/.bash_aliases"
    if ! grep -q "alias docker=podman" "$BASH_ALIAS" 2>/dev/null; then
        echo "alias docker=podman" >> "$BASH_ALIAS"
        chown "$TARGET_USER:$TARGET_USER" "$BASH_ALIAS"
    fi
fi

echo -e "\n${GREEN}${BOLD}✔ Moteur Podman configuré avec succès.${NC}"
echo -e "${BLUE}------------------------------------------------------"
echo -e "Utilisateur : $TARGET_USER"
echo -e "Quadlets    : $USER_HOME/.config/containers/systemd/"
echo -e "Linger      : Activé (Services persistants au reboot)"
echo -e "Ports       : Accès rootless dès le port 80 autorisé"
echo -e "------------------------------------------------------${NC}"