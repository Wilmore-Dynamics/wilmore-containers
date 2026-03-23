# <p align="center">Wilmore Containers</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Wilmore-Dynamics/design/refs/heads/main/assets/logo-cream.svg" width="96" alt="Logo Wilmore Dynamics">
</p>

<p align="center">
  <strong>Déploiement souverain de moteurs de conteneurisation.</strong>
</p>

---

## Philosophie
Extension logicielle de l'Atelier. Ce dépôt permet d'installer et de configurer des environnements de conteneurs (**Docker** ou **Podman**) en respectant les principes de privilèges minimaux et d'isolation.

## Capacités v0.1.0 "Foundations"
* **Sélecteur de Moteur :** Script d'installation intelligent (Docker CE ou Podman Rootless).
* **Hardened Docker :** Configuration du démon avec limitation des logs et isolation `userns`.
* **Podman Rootless :** Mise en place d'un environnement sans privilèges root (Souveraineté maximale).
* **Optimisation Réseau :** Configuration des ponts (bridges) compatible avec le firewalling Wilmore.

## Prérequis
Il est vivement recommandé d'avoir préalablement sécurisé l'hôte avec [Hardened Debian](https://github.com/Wilmore-Dynamics/hardened-debian).

## Installation & Usage
```bash
git clone https://github.com/Wilmore-Dynamics/wilmore-containers.git
cd wilmore-containers
chmod +x install.sh
sudo ./install.sh
```
Structure

- `/engines` : Scripts d'installation et de configuration (Docker/Podman).

- `/stacks` : Blueprints et fichiers Compose durcis.

- `/tools` : Utilitaires de maintenance et de backup des volumes.

<p align="right">
<sub>© 2026 Wilmore Dynamics. Moins, mais mieux.</sub>
</p>
