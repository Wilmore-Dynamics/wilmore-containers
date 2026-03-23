#!/bin/bash
# Wilmore Containers - Tool: UFW-Docker Patch v1.0
# Forcer Docker à respecter la souveraineté de UFW.

set -e
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo "Erreur: Lancez avec sudo."
   exit 1
fi

echo -e "${GREEN}[*] Téléchargement du module de routage ufw-docker...${NC}"
curl -s https://raw.githubusercontent.com/chaifeng/ufw-docker/master/ufw-docker -o /usr/local/bin/ufw-docker
chmod +x /usr/local/bin/ufw-docker

echo -e "${GREEN}[*] Injection des règles de filtrage dans UFW...${NC}"
# Cette commande modifie /etc/ufw/after.rules pour intercepter le trafic Docker
ufw-docker install

echo -e "${GREEN}[*] Redémarrage des services réseau...${NC}"
systemctl restart ufw
systemctl restart docker

echo -e "${GREEN}${BOLD}✔ Succès : Docker est désormais bridé par UFW.${NC}"
echo -e "------------------------------------------------------"
echo -e "Désormais, pour ouvrir un port vers un container :"
echo -e "Exemple : ${BOLD}ufw-docker allow nginx 80/tcp${NC}"
echo -e "------------------------------------------------------"