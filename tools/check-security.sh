#!/bin/bash
# Wilmore Containers - Tool: Security Auditor v1.1
# Audit de conformité compatible Debian PATH & Permissions.

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
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

# 1. Kernel Ports
PORT_START=$(sysctl -n net.ipv4.ip_unprivileged_port_start)
if [ "$PORT_START" -le 80 ]; then
    check_status 0 "Ports non-privilégiés autorisés dès le port $PORT_START"
else
    check_status 1 "Ports restreints (Attendu: <=80)"
fi

# 2. Linger (Méthode officielle systemd)
if loginctl show-user "$TARGET_USER" --property=Linger | grep -q "yes"; then
    check_status 0 "Mode Linger activé pour '$TARGET_USER'"
else
    check_status 1 "Mode Linger désactivé"
fi

# 3. SubUID/SubGID (Lecture via sudo pour éviter les erreurs de droits)
if sudo grep -q "$TARGET_USER" /etc/subuid 2>/dev/null; then
    check_status 0 "Plages UID/GID configurées dans /etc/subuid"
else
    check_status 1 "Plages UID/GID manquantes"
fi

# 4. Podman Isolation
if podman run --rm alpine true 2>/dev/null; then
    check_status 0 "Isolation Rootless fonctionnelle"
else
    check_status 1 "Échec du moteur Podman"
fi

# 5. UFW (Chemin absolu pour Debian)
UFW_BIN="/usr/sbin/ufw"
if [ -f "$UFW_BIN" ] && sudo $UFW_BIN status | grep -q "active"; then
    check_status 0 "Firewall UFW est actif"
else
    check_status 1 "Firewall UFW inaccessible ou désactivé"
fi

echo "------------------------------------------------------"
[ "$EXIT_CODE" -eq 1 ] && echo -e "${RED}${BOLD}❌ Alerte : Des failles détectées.${NC}" || echo -e "${GREEN}${BOLD}✅ Félicitations : Audit 100% Vert.${NC}"