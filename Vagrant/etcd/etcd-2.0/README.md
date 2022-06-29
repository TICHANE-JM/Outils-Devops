# Exécution d'un cluster etcd 2.0 sur Ubuntu 14.04

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) pour lancer rapidement et relativement facilement un cluster exécutant etcd 2.0 (etcd 2.0. 9 était la version spécifiquement testée). La configuration a été testée avec Vagrant 1.7.2, VMware Fusion 6.0.5 et le plugin Vagrant VMware.

## Contenu

* **etcd.conf**: Ceci est un script Upstart (écrit pour Ubuntu) pour démarrer etcd. Aucune modification de ce fichier ne devrait être nécessaire. Ce fichier est installé par le script d'approvisionnement appelé dans `Vagrantfile`.

* **etcd.defaults.erb**: Un modèle utilisé par Vagrant pour créer des fichiers par défaut de service spécifiques à la machine pour chaque nœud du cluster etcd. Le fichier spécifique au nœud approprié est installé en tant que `etcd` dans le répertoire `/etc/default` sur chaque nœud par le script de provisionnement appelé dans `Vagrantfile`.

* **provision.sh**: Ce script d'approvisionnement est appelé par l'approvisionneur du shell dans `Vagrantfile`. Il télécharge la version etcd 2.0.9 de GitHub, la développe, crée les répertoires nécessaires et place les fichiers aux emplacements appropriés. Enfin, il démarre etcd (ou le redémarre s'il est déjà en cours d'exécution).

* **README.md**: Ce fichier que vous lisez actuellement.

* **servers.yml**: Ce fichier YAML contient une liste de définitions de VM. Il est référencé par `Vagrantfile` lorsque Vagrant instancie les VM. Vous devrez peut-être modifier ce fichier pour fournir les adresses IP appropriées et d'autres données de configuration de machine virtuelle (voir « Instructions » ci-dessous). _Si vous modifiez les noms d'hôte ou les adresses IP fournis dans ce fichier, vous **devez** également modifier les fichiers de remplacement d'Upstart._

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les machines virtuelles. Ce fichier est assez largement commenté pour aider à expliquer ce qui se passe. Vous devriez pouvoir utiliser ce fichier tel quel ; toutes les options de configuration de la machine virtuelle sont stockées en dehors de ce fichier.

## Instructions

Ces instructions supposent que vous avez déjà installé votre fournisseur de virtualisation back-end (VMware Fusion ou VirtualBox), Vagrant et tous les plug-ins nécessaires (tels que le plug-in Vagrant VMware). Reportez-vous à la documentation de ces produits pour plus d'informations sur l'installation ou la configuration.

1. Utilisez `vagrant box add` pour installer une boîte de base Ubuntu 14.04 x64. Pour une boîte au format VirtualBox, utilisez "ubuntu/trusty64". Pour une box au format VMware, le « bento/ubuntu-14.04 » est une bonne option. (En théorie, vous devriez également pouvoir utiliser cet environnement Vagrant avec VMware Workstation, mais seul VMware Fusion a été testé.)

2. Placez les fichiers du répertoire `etcd-2.0` de ce référentiel GitHub (le référentiel "TICHANE-JM/Outils-Devops") dans un répertoire de votre système. Vous pouvez cloner l'intégralité du référentiel "Outils-Devops" (en utilisant `git clone`), ou simplement télécharger les fichiers spécifiques à partir du répertoire `etcd-2.0`.

3. Modifiez `machines.yml` pour vous assurer que la boîte spécifiée dans ce fichier correspond à la boîte de base Ubuntu 14.04 x64 que vous venez d'installer et que vous utiliserez. _Je vous recommande de ne modifier aucune autre valeur dans ce fichier, sauf si vous savez que c'est nécessaire._

4. À partir d'une fenêtre de terminal, accédez au répertoire dans lequel les fichiers de ce répertoire sont stockés et exécutez `vagrant up` pour afficher les machines virtuelles spécifiées dans `machines.yml` et `Vagrantfile`.

5. Une fois que Vagrant a fini de créer, démarrer et provisionner chacune des machines virtuelles et de démarrer etcd, connectez-vous au premier système ("etcd-01" par défaut) en utilisant `vagrant ssh etcd-01`.

6. Vous pouvez tester etcd avec cette commande :

		etcdctl member list
	
	Cela devrait renvoyer une liste de trois nœuds en tant que membres du cluster etcd. Si vous recevez une erreur ou si vous ne voyez pas les trois machines virtuelles répertoriées, détruisez l'environnement Vagrant avec "vagrant destroy" et recréez l'environnement à partir de zéro. Si vous continuez à rencontrer des problèmes, ouvrez un problème ici sur GitHub (ou déposez une demande d'extraction résolvant le problème).

Eclatez-vous !
