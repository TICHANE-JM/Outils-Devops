# Utilisation de Vagrant avec AWS (instances multiples)

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ( http://www.vagrantup.com ) avec AWS, où les machines virtuelles gérées par 
Vagrant sont en fait des instances exécutées sur AWS. Cet environnement peut être utilisé pour lancer plusieurs instances. 

## Contenu

* **instances.yml** : Ce fichier YAML contient les informations de configuration spécifiques à l'instance. Quatre valeurs sont attentues dans ce fichier : `name`(un nom convivial pour l'instance, ne sera pas honoré par AWS),, `type` (le type d'instance, tel que "m3.medium") `ami` , et `user`.
* **Vagrantfile** : Ce fichier est utilisé par Vagrant pour lancer l'instance OpenStack. deux modifications **doivent** être apportées à ce fichier pour qu'il fonctionne correctement : vous devez spécifier le chemin d'accès correct à votre clé privée SSH (la clé privée de la paire de clés spécifiées dans`instances.yml` ), et vous devez fournir le nom correct au boîte factice installée pour une utilisation avec AWS.

## Instructions

Ces instructions supposent que vous disposez d'un compte AWS, que vous connaissez votre ID de clé d'accès AWS et votre clé d'accès secrète, et que vous disposez d'une paire de clés SSH valide configurée dans votre compte AWS.

1. Vagrant exige qu'une "boîte factice" soit installée pour être utilisée avec AWS. Exécutez cette commande pour installer le boîtier factice :

`vagrant box add <box-name> https://github.com/TICHANE-JM/Outils-Devops/blob/main/Vagrant/AWS/vagrant-aws-master/dummy.box`

2. Installez le fournisseur AWS Vagrant en exécutant `vagrant plugin install vagrant-aws`.
3. Placez les fichiers du répertoire `vagrant-aws-multi` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel (à l'aide de git clone), télécharger un fichier ZIP de l'intégralité du référentiel ou simplement télécharger les fichiers spécifiques à partir du dossier `vagrant-aws-multi`.
4. Modifiez `instances.yml`pour fournir les informations correcte à utiliser par Vagrant lors du lancement d'une instance sur AWS. Vous devrez spécifier le nom , le type d'instance, l'ID d'AMI et l'utilisateur SSH par défait pour l'AMI.
5. Dans la fenêtre du terminal, définissez les variables d'environnement `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` sur , respectivement, notre ID de clé d'accès AWS et votre clé d'accès secrète AWS.
6. Dans le répertoire où vous avez placé les fichiers de ce référentiel GitHub, exécutez `vagrant up` pour que Vagrant s'authentifie auprès d'AWS et lance les instances souhaitées pour vous. Une fois l'instance créée, vous pouvez utiliser `vagrant ssh <name>` pour vous connecter à une instance particulière et `vagrant destroy` mettre fin (détruire) les instances AWS. (Vous pouvez suivre toutes ces actions dans AWS Management Console, si vous le souhaitez.)

Eclatez-vous !!

## Notes complémentaires

Cet environnement est un complément à l'environnement présent dans l'annuaire `vagrant-aws` ou cet environnement ne vous permet de lancer qu'une seule instance à l'aide de Vagrant, alors que cet environnement prend en charge la création de plusieurs instances.
