# Exécution de plusieurs conteneurs Docker dans Vagrant avec YAML

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) 
pour lancer rapidement et relativement facilement plusieurs Docker ([http://www.docker.com](http://www.docker.com)) containers. 
Les spécificités des conteneurs Docker sont spécifiées dans un fichier YAML externe. La configuration a été testée avec Vagrant 1.8.5,
VMware Fusion 8.1.0 (avec le plug-in Vagrant VMware) et VirtualBox 5.1.

## Contenu

* **containers.yml**: Ce fichier YAML contient une liste des conteneurs Docker et leurs propriétés à utiliser par Vagrant. Vous devrez modifier ce fichier pour spécifier le nom convivial du conteneur, l'image et les ports exposés.

* **hostvms.yml**: Ce fichier YAML contient les données de configuration de la "VM hôte" que le fournisseur Vagrant Docker utilisera. Modifiez ce fichier pour modifier la case Vagrant utilisée par la "VM hôte" ou la configuration de la VM.

* **README.md**: Le fichier que vous êtes en train de lire.

* **VagrantfileHost**: Ce fichier est utilisé par Vagrant pour créer une "machine virtuelle hôte" à utiliser avec le fournisseur Vagrant Docker. Aucune modification ne devrait être nécessaire pour ce fichier.

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les conteneurs Docker sur la machine virtuelle hôte créée par `VagrantfileHost`. À moins que vous ne changiez les noms de fichiers, vous ne devriez pas avoir besoin de modifier ce fichier. Tous les détails du conteneur sont stockés dans un fichier YAML séparé.

## Instructions

1. Utilisez `vagrant box add` pour installer une boîte de base Ubuntu 14.04. Pour une boîte au format VMware, la boîte « bento/ubuntu-14.04 » est une bonne option ; sur VirtualBox, vous pouvez utiliser la boîte "ubuntu/trusty64".

2. Modifiez `hostvms.yml` pour spécifier le nom de la boîte que vous avez ajoutée à l'étape 1.

3.Modifiez le fichier `containers.yml` pour spécifier les conteneurs Docker que Vagrant doit créer sur la machine virtuelle hôte. Chaque conteneur doit contenir trois propriétés : `name` (le nom convivial à attribuer au conteneur Docker), `image` (le nom de l'image Docker à utiliser pour ce conteneur) et `ports` (une liste de ports à exposer pour le contenant).

4. À partir du répertoire où se trouve le `Vagrantfile` principal, exécutez simplement `vagrant up` pour faire tourner la machine virtuelle hôte spécifiée et les conteneurs Docker spécifiés. Notez qu'un accès Internet **sera** nécessaire pour télécharger Docker et les images Docker.

Eclatez-vous !
