#!/bin/bash
# Wilmore Containers - Tool: Quadlet Deployer
# Déploie un fichier .container vers le gestionnaire systemd.

SERVICE_NAME=$1
QUADLET_SOURCE="$HOME/stacks/$SERVICE_NAME/$SERVICE_NAME.container"
QUADLET_TARGET="$HOME/.config/containers/systemd/$SERVICE_NAME.container"

if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: ./deploy-quadlet.sh <nom_du_service>"
    exit 1
fi

if [ ! -f "$QUADLET_SOURCE" ]; then
    echo "Erreur : Le fichier $QUADLET_SOURCE n'existe pas."
    exit 1
fi

echo "[*] Déploiement du Quadlet : $SERVICE_NAME"
cp "$QUADLET_SOURCE" "$QUADLET_TARGET"

echo "[*] Rechargement de systemd..."
systemctl --user daemon-reload
systemctl --user restart "$SERVICE_NAME.service"

echo "✅ Service $SERVICE_NAME déployé et activé."