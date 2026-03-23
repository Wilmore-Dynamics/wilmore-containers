#!/bin/bash
# Wilmore Containers - Engine: Docker CE
# Philosophie : Dépôts officiels & Limites de ressources.

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[*] Préparation de l'environnement Docker...${NC}"

# 1. Nettoyage des versions obsolètes (si présentes)
apt-get remove -y -qq docker docker-engine docker.io containerd runc 2>/dev/null || true

# 2. Installation des dépendances de transport
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg lsb-release > /dev/null

# 3. Ajout de la clé GPG officielle Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes

# 4. Configuration du dépôt stable
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Installation du moteur Docker
echo -e "${GREEN}[*] Installation de Docker CE & Compose Plugin...${NC}"
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null

# 6. Configuration du Daemon (La "Wilmore Touch")
# On limite les logs à 10MB et 3 fichiers pour éviter la saturation disque.
echo -e "${GREEN}[*] Application des limites de ressources (daemon.json)...${NC}"
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true
}
EOF

# 7. Gestion du groupe utilisateur
# On ajoute l'utilisateur actuel au groupe docker pour éviter le sudo systématique
TARGET_USER="${SUDO_USER:-$USER}"
usermod -aG docker "$TARGET_USER"

# 8. Redémarrage du service
systemctl restart docker
systemctl enable docker > /dev/null

echo -e "${GREEN}${BOLD}✔ Docker CE installé et configuré avec succès.${NC}"
echo -e "${YELLOW}ℹ Note : Déconnectez-vous et reconnectez-vous pour utiliser docker sans sudo.${NC}"