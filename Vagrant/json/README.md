# Machine virtuelle Debian 8.0 ("Jessie") générique

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) pour démarrer rapidement et facilement une machine virtuelle générique Debian 8.0 ("Jessie") 64 bits. La configuration a été testée avec Vagrant 1.7.2, VMware Fusion 6.0.5 et le plug-in Vagrant VMware.

**REMARQUE :** Il n'y a vraiment rien de spécial ici ; J'ai créé ces fichiers parce que j'avais souvent besoin de faire tourner rapidement et facilement une machine virtuelle Debian générique dans un but précis (construire un paquet ou tester une commande). Je les inclue ici juste par souci d'exhaustivité.

## Contenu

* **README.md**:Ce fichier que vous lisez actuellement.

* **machines.json**: Ce fichier JSON contient une liste de définitions de VM et les données de configuration associées. Il est référencé par `Vagrantfile` lorsque Vagrant instancie les VM.

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les machines virtuelles. Ce fichier est assez largement commenté pour aider à expliquer ce qui se passe. Vous devriez pouvoir utiliser ce fichier tel quel ; toutes les options de configuration de la machine virtuelle sont stockées en dehors de ce fichier.

## Instructions

Ces instructions supposent que vous avez déjà installé VMware Fusion, Vagrant et le plug-in Vagrant VMware. Reportez-vous à la documentation de ces produits pour plus d'informations sur l'installation ou la configuration.

1.Utilisez `vagrant box add` pour ajouter une boîte de base Debian 8.0 ("Jessie") 64 bits à utiliser par ce `Vagrantfile`. Vous devrez spécifier une case qui fournit la prise en charge du fournisseur `vmware_desktop` (cela devrait fonctionner avec VMware Workstation ou VMware Fusion).

2. Modifiez le fichier `machiness.json` pour vous assurer que la boîte que vous avez téléchargée à l'étape 1 est spécifiée sur la ligne "boîte :" de ce fichier.

3. Exécutez `vagrant up`, et lorsque la VM est en marche, utilisez `vagrant ssh` pour accéder à la VM Debian générique.

Eclatez-vous!
