#!/bin/bash
# Wilmore Containers - v0.1.0 "Foundations"
# Sélecteur de moteur de conteneurisation.

set -e

# --- Couleurs Wilmore ---
GREEN='\033[0;32m'
BOLD='\033[1m'
RED='\033[0;31m'
NC='\033[0m'

print_logo() {
    clear
    echo -e "${GREEN}${BOLD}"
    echo "      __      __.__ .__                                "
    echo "     /  \    /  \__|  |   _____   ___________   ____   "
    echo "     \   \/\/   /  |  |  /     \ /  _ \_  __ \_/ __ \  "
    echo "      \        /|  |  |_|  Y Y  (  <_> )  | \/\  ___/  "
    echo "       \__/\  / |__|____/__|_|  /\____/|__|    \___  > "
    echo "            \/                \/                   \/  "
    echo "                CONTAINER ATELIER v0.1.0"
    echo -e "${NC}"
}

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur: Wilmore nécessite des privilèges root pour installer les moteurs.${NC}"
   exit 1
fi

print_logo

echo -e "${BOLD}Quel moteur souhaitez-vous déployer sur votre base Hardened ?${NC}"
echo "------------------------------------------------------------"
echo "1) Docker CE (Standard, puissant, avec Daemon)"
echo "2) Podman (Souverain, Rootless, sans Daemon)"
echo "3) Quitter"
echo ""
read -p "Choix [1-3] : " engine_choice

case $engine_choice in
    1)
        echo -e "\n${GREEN}[*] Lancement de l'installation Docker CE...${NC}"
        bash engines/docker.sh
        ;;
    2)
        echo -e "\n${GREEN}[*] Lancement de l'installation Podman Rootless...${NC}"
        bash engines/podman.sh
        ;;
    3)
        echo -e "Retour à l'atelier. À bientôt."
        exit 0
        ;;
    *)
        echo -e "${RED}Option invalide.${NC}"
        exit 1
        ;;
esac