# Exécuter Docker avec Vagrant


Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) pour lancer rapidement et relativement facilement un ou plusieurs containers Docker ([http://www.docker.com](http://www.docker.com)) . La configuration a été testée avec Vagrant 1.7.2, VMware Fusion 6.0.5 et le plug-in Vagrant VMware.

## Contenu

* **README.md**: Le fichier que vous êtes en train de lire.

* **host/Vagrantfile**: Ce fichier est utilisé par Vagrant pour créer une "machine virtuelle hôte" à utiliser avec le fournisseur Vagrant Docker. Modifiez ce fichier pour changer la boîte Vagrant que vous souhaitez utiliser ; par défaut, ce Vagrantfile utilise la boîte "bento/ubuntu-14.04" (inclut le support du fournisseur "vmware_desktop").

* **Vagrantfile**:Ce fichier est utilisé par Vagrant pour faire tourner les conteneurs Docker sur la machine virtuelle hôte créée par `host/Vagrantfile`. Modifiez ce fichier pour modifier l'une des propriétés du conteneur Docker que vous souhaitez créer par Vagrant.

## Instructions

1. Si vous souhaitez utiliser une boîte _autre_ que la boîte "bento/ubuntu-14.04" (sous Ubuntu 14.04), modifiez le `Vagrantfile` dans le sous-répertoire host.

2. Si vous souhaitez exécuter un conteneur Docker avec une image _autre_ que l'image Nginx standard, modifiez le "Vagrantfile" principal et spécifiez une nouvelle image.

3. À partir du répertoire où se trouve le `Vagrantfile` principal, exécutez simplement `vagrant up` pour faire tourner la machine virtuelle hôte spécifiée et les conteneurs Docker spécifiés. Notez qu'un accès Internet **sera** nécessaire pour télécharger Docker et les images Docker.

Eclatez-vous !
