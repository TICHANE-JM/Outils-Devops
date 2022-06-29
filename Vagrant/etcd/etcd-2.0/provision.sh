#!/bin/bash

# installez curl si nécessaire
if [[ ! -e /usr/bin/curl ]]; then
  apt-get update
  apt-get -yqq install curl
fi

if [[ ! -e /usr/local/bin/etcd ]]; then
  # Télécharger etcd
  curl -sL  https://github.com/coreos/etcd/releases/download/v2.0.9/etcd-v2.0.9-linux-amd64.tar.gz -o etcd-v2.0.9-linux-amd64.tar.gz

  # Décompresser le fichier téléchargé
  tar xzvf etcd-v2.0.9-linux-amd64.tar.gz

  # Déplacez etcd et etcdctl vers /usr/local/bin
  cd etcd-v2.0.9-linux-amd64
  sudo mv etcd /usr/local/bin/
  sudo mv etcdctl /usr/local/bin/
  cd ..

  # Supprimer le téléchargement et le répertoire etcd
  rm etcd-v2.0.9-linux-amd64.tar.gz
  rm -rf etcd-v2.0.9-linux-amd64

  # Créer les répertoires nécessaires à etcd
  sudo mkdir -p /var/etcd
fi

# Copiez les fichiers aux bons emplacements ; nécessite des dossiers partagés
sudo cp /home/vagrant/etcd.conf /etc/init/etcd.conf
sudo cp /home/vagrant/etcd.defaults /etc/default/etcd

# redémarrer s'il est déjà en cours d'exécution, sinon démarrer.
initctl status etcd && initctl restart etcd || initctl start etcd
