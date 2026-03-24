#!/bin/bash
# Wilmore Containers - v0.2.0 "Resilience"
# Console de gestion de l'Atelier.

set -e

GREEN='\033[0;32m'
BOLD='\033[1m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
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
    echo "                CONTAINER ATELIER v0.2.0"
    echo -e "${NC}"
}

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur: Wilmore nécessite des privilèges root.${NC}"
   exit 1
fi

main_menu() {
    print_logo
    echo -e "${BOLD}Gestion des moteurs et outils de souveraineté${NC}"
    echo "------------------------------------------------------------"
    echo -e "${BLUE}[ MOTEURS ]${NC}"
    echo "1) Installer Docker CE (Standard)"
    echo "2) Installer Podman Rootless (Souverain)"
    echo ""
    echo -e "${BLUE}[ MAINTENANCE ]${NC}"
    echo "3) Audit de Sécurité (Check-Security)"
    echo "4) Sauvegarder les Stacks (Backup)"
    echo ""
    echo -e "${BLUE}[ RÉSEAU ]${NC}"
    echo "5) Appliquer le Patch UFW-Docker"
    echo "6) Quitter"
    echo "------------------------------------------------------------"
    read -p "Choix [1-6] : " choice

    case $choice in
        1) bash engines/docker.sh ;;
        2) bash engines/podman.sh ;;
        3) sudo -u "${SUDO_USER:-$USER}" bash tools/check-security.sh ;;
        4) bash tools/backup-stacks.sh ;;
        5) bash tools/ufw-docker-patch.sh ;;
        6) echo "À bientôt."; exit 0 ;;
        *) echo -e "${RED}Invalide.${NC}"; sleep 1; main_menu ;;
    esac
}

main_menu