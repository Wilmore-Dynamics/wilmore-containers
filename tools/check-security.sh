#!/bin/bash
# Wilmore Containers - Tool: Security Auditor v1.0
# Audit de conformité de l'environnement Rootless & Hardening.

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

TARGET_USER="${SUDO_USER:-$USER}"

echo -e "${BOLD}🔍 Audit de Sécurité Wilmore - $(date)${NC}"
echo "------------------------------------------------------"

check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "[ ${GREEN}OK${NC} ] $2"
    else
        echo -e "[ ${RED}FAIL${NC} ] $2"
        EXIT_CODE=1
    fi
}

# 1. Vérification du Kernel (Privileged Ports)
PORT_START=$(sysctl -n net.ipv4.ip_unprivileged_port_start)
if [ "$PORT_START" -le 80 ]; then
    check_status 0 "Ports non-privilégiés autorisés dès le port $PORT_START"
else
    check_status 1 "Ports non-privilégiés restreints (Actuel: $PORT_START, Attendu: <=80)"
fi

# 2. Vérification du mode Linger (Persistance)
if ls /var/lib/systemd/linger/ | grep -q "$TARGET_USER"; then
    check_status 0 "Mode Linger activé pour l'utilisateur '$TARGET_USER'"
else
    check_status 1 "Mode Linger désactivé (Les containers mourront après SSH logout)"
fi

# 3. Vérification des SubUID/SubGID
if grep -q "$TARGET_USER" /etc/subuid && grep -q "$TARGET_USER" /etc/subgid; then
    check_status 0 "Namespaces UID/GID configurés pour le mode Rootless"
else
    check_status 1 "Plages UID/GID manquantes dans /etc/subuid"
fi

# 4. Vérification de l'isolation des processus (Rootless check)
if [ "$EUID" -ne 0 ]; then
    if podman run --rm alpine true 2>/dev/null; then
        check_status 0 "Isolation Rootless fonctionnelle (Test 'podman run' réussi)"
    else
        check_status 1 "Échec du lancement Podman en mode utilisateur"
    fi
else
    echo -e "[ ${YELLOW}WARN${NC} ] Vous lancez l'audit en ROOT. L'isolation doit être testée en utilisateur."
fi

# 5. Vérification du Firewall (UFW)
if ufw status | grep -q "Status: active"; then
    check_status 0 "Firewall UFW est actif"
else
    check_status 1 "Firewall UFW est désactivé (Surface d'attaque exposée)"
fi

echo "------------------------------------------------------"
if [ "$EXIT_CODE" -eq 1 ]; then
    echo -e "${RED}${BOLD}❌ Alerte : Des failles de configuration ont été détectées.${NC}"
else
    echo -e "${GREEN}${BOLD}✅ Félicitations : Votre atelier est une forteresse.${NC}"
fi