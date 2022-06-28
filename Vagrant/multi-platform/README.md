# Environnement Vagrant Multiplateforme

Ces fichiers ont été créés pour tester une méthode de fourniture d'un seul environnement Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) pouvant prendre en charge plusieurs plates-formes de virtualisation locales sans aucune modification du `Vagrantfile` ou fichiers de configuration de support. Cette configuration a été testée avec les composants suivants :

* Vagrant 1.9.7 avec VirtualBox 5.1.26 sur OS X 10.12.6 en utilisant la boîte Vagrant officielle "debian/jessie64"
* Vagrant 1.9.7 avec VMware Fusion 10.1.1 sur OS X 10.12.6 en utilisant la boîte Vagrant "bento/debian-8.6"

## Contenu

* **machines.yml**:Ce fichier YAML contient une liste de définitions de VM et les données de configuration associées. Il est référencé par `Vagrantfile` lorsque Vagrant instancie les VM. Des définitions de boîtes distinctes sont incluses : "vb_box" pour VirtualBox, "vmw_box" pour VMware Fusion.

* **README.md**: Ce fichier que vous lisez actuellement.

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les machines virtuelles. Ce fichier est assez largement commenté pour aider à expliquer ce qui se passe. Vous devriez pouvoir utiliser ce fichier tel quel ; toutes les options de configuration de la machine virtuelle sont stockées en dehors de ce fichier.

## Instructions

Ces instructions supposent que vous avez déjà installé Vagrant, le ou les fournisseurs de virtualisation back-end nécessaires (seuls VirtualBox et VMware Fusion sont pris en charge par cet environnement de test) et tous les plug-ins nécessaires. Reportez-vous à la documentation de ces produits pour plus d'informations sur l'installation ou la configuration.

1. Utilisez `vagrant box add` pour ajouter une boîte VirtualBox et/ou une boîte VMware Fusion (toute boîte marquée avec le fournisseur "vmware_desktop" fonctionnera avec Fusion). Si VMware Fusion et VirtualBox sont installés sur le même système, installez un boîtier pour les deux plates-formes.

2. Modifiez le fichier `machines.yml` pour vous assurer que la ou les boîtes que vous avez téléchargées à l'étape 1 sont spécifiées dans ce fichier. Placez le nom de la boîte VirtualBox comme valeur pour "vb_box" ; fournissez le nom de la boîte VMware Fusion comme valeur pour "vmw_box".

3. Exécutez `vagabond'. Vagrant créera la VM en utilisant la case spécifiée dans `machines.yml`, en sélectionnant la case appropriée en fonction du fournisseur utilisé.

5. Pour des résultats idéaux, testez cet environnement sur différents systèmes avec différents fournisseurs (c'est-à-dire un système Linux exécutant VirtualBox et un système OS X exécutant VMware Fusion). Aucune modification ne devrait être nécessaire pour `Vagrantfile` ou `machines.yml` lorsque vous passez d'un système à l'autre.

Eclatez-vous !
