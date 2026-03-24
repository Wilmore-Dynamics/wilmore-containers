#!/bin/bash
# Wilmore Containers - Tool: Security Auditor v1.2
# Audit de conformité compatible Debian PATH & Multi-User context.

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Définition de l'utilisateur à auditer
# On privilégie la variable passée par le menu, puis le SUDO_USER, puis l'user actuel
AUDIT_USER="${TARGET_USER:-${SUDO_USER:-$USER}}"

# Sécurité : Si on tombe sur root, on bascule par défaut sur 'ab' (ton user atelier)
if [ "$AUDIT_USER" == "root" ]; then
    AUDIT_USER="ab"
fi

echo -e "${BOLD}🔍 Audit de Sécurité Wilmore - Utilisateur cible : ${BLUE}$AUDIT_USER${NC}"
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
PORT_START=$(sysctl -n net.ipv4.ip_unprivileged_port_start 2>/dev/null || echo "1024")
if [ "$PORT_START" -le 80 ]; then
    check_status 0 "Ports non-privilégiés autorisés dès le port $PORT_START"
else
    check_status 1 "Ports restreints (Attendu: <=80)"
fi

# 2. Linger (Vérification via systemd)
if loginctl show-user "$AUDIT_USER" --property=Linger | grep -q "yes"; then
    check_status 0 "Mode Linger activé pour '$AUDIT_USER'"
else
    check_status 1 "Mode Linger désactivé"
fi

# 3. SubUID/SubGID
if grep -q "$AUDIT_USER" /etc/subuid 2>/dev/null; then
    check_status 0 "Plages UID/GID configurées pour '$AUDIT_USER'"
else
    check_status 1 "Plages UID/GID manquantes dans /etc/subuid"
fi

# 4. Podman Isolation (Testé en contexte utilisateur si possible)
if sudo -u "$AUDIT_USER" podman run --rm alpine true 2>/dev/null; then
    check_status 0 "Isolation Rootless fonctionnelle"
else
    check_status 1 "Échec du moteur Podman (Vérifiez l'installation)"
fi

# 5. UFW (Vérification du service via systemctl pour éviter les problèmes de PATH)
if systemctl is-active --quiet ufw; then
    check_status 0 "Firewall UFW est actif"
else
    check_status 1 "Firewall UFW désactivé ou non installé"
fi

echo "------------------------------------------------------"
if [ "$EXIT_CODE" -eq 1 ]; then
    echo -e "${RED}${BOLD}❌ Alerte : Des failles de configuration ont été détectées.${NC}"
else
    echo -e "${GREEN}${BOLD}✅ Félicitations : Audit 100% Vert.${NC}"
fi