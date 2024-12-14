#!/bin/bash

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script en tant que root."
  exit 1
fi

# Installation des dépendances nécessaires pour Ansible
echo "Installation des dépendances..."
apt update
apt install -y ansible sshpass

# Création du fichier d'inventaire
echo "Création de l'inventaire Ansible..."
cat <<EOL > inventory
[all]
machine1 ansible_host=192.168.1.101 ansible_user=utilisateur ansible_ssh_pass=motdepasse
machine2 ansible_host=192.168.1.102 ansible_user=utilisateur ansible_ssh_pass=motdepasse
EOL

# Création du playbook Ansible
echo "Création du playbook Ansible pour installer Docker..."
cat <<EOL > playbook.yml
---
- name: Installer Docker sur des machines
  hosts: all
  become: yes
  tasks:
    - name: Mettre à jour les dépôts APT
      apt:
        update_cache: yes

    - name: Installer les dépendances pour Docker
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
        state: present

    - name: Ajouter la clé GPG officielle de Docker
      command: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    - name: Ajouter le dépôt Docker
      apt_repository:
        repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable
        state: present

    - name: Installer Docker
      apt:
        name: docker-ce
        state: latest

    - name: Activer et démarrer le service Docker
      systemd:
        name: docker
        enabled: yes
        state: started
EOL

# Lancer le playbook
echo "Exécution du playbook Ansible pour installer Docker..."
ansible-playbook -i inventory playbook.yml

echo "Installation de Docker terminée."
