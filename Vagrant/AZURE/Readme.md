# Utilisation de Vagrant avec Azure (instance unique)

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser [Vagrant](http://www.vagrantup.com) avec Azure, où les machines virtuelles gérées par Vagrant sont en fait des machines virtuelles Azure. En utilisant ces fichiers, Vagrant ne peut fonctionner que sur une seule instance à la fois. Cette configuration a été testée avec Vagrant 1.9.8, la version 2.0.0 du [plug-in vagrant-azure](https://github.com/azure/vagrant-azure) et Microsoft Azure.

## Contenu
* **instances.yml** : ce fichier YAML contient les informations de configuration spécifiques à l'instance. Quatre valeurs sont attendues dans ce fichier : `group`(le groupe de ressources Azure que Vagrant doit utiliser ; ce groupe ne doit pas déjà exister), `image`(l'image de machine virtuelle Azure à utiliser), `name`(le nom à attribuer à la machine virtuelle Azure) et `size` (la machine virtuelle taille à utiliser).

* **README.md** : Le fichier que vous êtes en train de lire.

* **Vagrantfile** : Ce fichier est utilisé par Vagrant pour faire tourner la machine virtuelle Azure. Deux modifications **doivent** être apportées à ce fichier pour qu'il fonctionne correctement : vous devez spécifier le chemin d'accès correct à votre clé privée SSH et vous devez fournir le nom correct à la boîte factice installée pour une utilisation avec Azure.

## Des instructions
Ces instructions supposent que vous disposez d'un abonnement Azure, que vous connaissez votre ID d'abonnement Azure (qui peut être obtenu en exécutant `az account show --query '[?isDefault].id' -o tsv` ) et que vous disposez d'une paire de clés SSH valide à utiliser pour vous connecter à la machine virtuelle Azure basée sur Linux.

1. Vagrant nécessite qu'une "boîte factice" soit installée pour être utilisée avec Azure. Exécutez cette commande pour installer le boîtier factice :

 `vagrant box add <box-name> https://github.com/azure/vagrant-azure/raw/v2.0/dummy.box --provider azure`
 
2. Installez le fournisseur Vagrant Azure en exécutant `vagrant plugin install vagrant-azure`.

3. __(Une seule fois)__ Créez un service principal d'Azure Active Directory que Vagrant utilisera lors de la connexion à Azure. Vous pouvez le faire avec la commande `az ad sp create-for-rbac`. Enregistrez et conservez la sortie JSON ; vous en aurez besoin plus tard.

4. Placez les fichiers du `vagrant-azure` répertoire de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel (à l'aide de `git clone`), télécharger un fichier ZIP de l'intégralité du référentiel "Outils-Devops" ou simplement télécharger les fichiers spécifiques à partir du `vagrant-azure` dossier.

5. Modifiez `instances.yml` pour fournir les informations correctes à utiliser par Vagrant lors du lancement d'une machine virtuelle sur Azure.

6. Dans une fenêtre de terminal, définissez quelques variables d'environnement :

  Pour AZURE_TENANT_ID, utilisez la valeur « locataire » de la sortie JSON de l'étape 3.

  Pour AZURE_CLIENT_ID, utilisez la valeur "appID" de la sortie JSON de l'étape 3.

  Pour AZURE_CLIENT_SECRET, utilisez la valeur "password" de la sortie JSON de l'étape 3.

  Pour AZURE_SUBSCRIPTION_ID, utilisez votre ID d'abonnement Azure.

7. Dans le répertoire où vous avez placé les fichiers de ce référentiel GitHub, exécutez `vagrant up` pour que Vagrant s'authentifie auprès d'Azure et lance la machine virtuelle souhaitée pour vous. Une fois la machine virtuelle créée et en cours d'exécution, vous pouvez l'utiliser `vagrant ssh` pour vous connecter à l'instance et `vagrant destroy` arrêter (détruire) la machine virtuelle Azure pour vous. (Vous pouvez suivre toutes ces actions dans le portail Azure, si cela vous intéresse.)

Allez éclatez-vous !

## Notes complémentaires
Cet environnement ne créera qu'une seule instance sur Azure à l'aide de Vagrant. Un environnement permettant de faire tourner plusieurs instances est prévu dans un futur proche.
