# Exécution de plusieurs conteneurs Docker dans Vagrant avec JSON

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com))pour lancer rapidement et relativement facilement plusieurs conteneurs Docker ([http://www.docker.com](http://www.docker.com)). Les spécificités des conteneurs Docker sont spécifiées dans un fichier JSON externe. La configuration a été testée avec Vagrant 1.8.1, VMware Fusion 8.1.0 et le plug-in Vagrant VMware.

## Contenu

* **containers.json**: Ce fichier JSON contient une liste des conteneurs Docker et leurs propriétés à utiliser par Vagrant. Si vous ne souhaitez pas utiliser les valeurs par défaut, vous devrez modifier ce fichier pour spécifier le nom convivial du conteneur, l'image et les ports exposés.

* **host/Vagrantfile**: Ce fichier est utilisé par Vagrant pour créer une "machine virtuelle hôte" à utiliser avec le fournisseur Vagrant Docker. Modifiez ce fichier pour changer la boîte Vagrant que vous souhaitez utiliser ; par défaut, ce Vagrantfile utilise la boîte "bento/ubuntu-14.04" (inclut le support du fournisseur "vmware_desktop").

* **README.md**: Le fichier que vous êtes en train de lire.

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les conteneurs Docker sur la machine virtuelle hôte créée par `host/Vagrantfile`. À moins que vous ne changiez les noms de fichiers, vous ne devriez pas avoir besoin de modifier ce fichier. Tous les détails du conteneur sont stockés dans un fichier de données encodé JSON séparé.

## Instructions

1. Si vous souhaitez utiliser une boîte _autre_ que la boîte "bento/ubuntu-14.04" (sous Ubuntu 14.04), modifiez le `Vagrantfile` dans le sous-répertoire `host`.

2. Modifiez le fichier `containers.json` pour spécifier les conteneurs Docker que Vagrant doit créer sur la machine virtuelle hôte (spécifiés par `host/Vagrantfile`). Chaque conteneur doit contenir trois propriétés : `name` (le nom convivial à attribuer au conteneur Docker), `image` (le nom de l'image Docker à utiliser pour ce conteneur) et `ports` (une liste de ports à exposer pour le contenant).

3. À partir du répertoire où se trouve le `Vagrantfile` principal, exécutez simplement `vagrant up` pour faire tourner la machine virtuelle hôte spécifiée et les conteneurs Docker spécifiés. Notez qu'un accès Internet **sera** nécessaire pour télécharger Docker et les images Docker.

Eclatez vous !
