# VAGRANT avec AWS (instance unique)

Les fichiers contenu dans ce répertoire permettent aux utilisateurs d'utiliser [Vagrant](http://www.vagrantup.com) avec AWS. Les machines virtuelles gérées par Vagrant sont des instances exécutées sur AWS. En utilisant ces fichiers, Vagrant n'effectuera qu'une seule instance à la fois.  Cette configuration a été testée avec Vagrant 2.2.19, le [plugin Vagrant-AWS](https://github.com/mitchellh/vagrant-aws) et AWS.

## Contenu

* **instances.yml** : Ce fichier YAML contient les informations de configuration spécifiques à l'instance. Six valeurs sont attendues dans ce fichier : `ìnstance_type` (le type d'instance, tel que "m3.medium"), `region`, `ami`, `user`, `security_groups` et `keypair_name` .

* **Vagrantfile** : Ce fichier est utilisé par Vagrant pour lancer l'instance AWS. deux modifications **doivent** être apportées à ce fichier pour qu'il fonctionne correctement : vous devez spécifier le chemin d'accès correct à votre clé privée SSH (la clé privée `keypair_name` spécifiées dans `instances.yml`), et n'oubliez pas de fournir le nom correct à la boîte installée pour une utilisation avec AWS.

## Instructions :

On va partir du fait que vous disposez d'un compte AWS, que vous connaissez votre ID de clé d'accès AWS et votre clé d'accès secrète, et que vous disposez d'une paire de clés SSH valide configurée dans votre compte AWS.

1. Vagrant exige qu'une "boîte`factice" soit installée pour être utilisée avec AWS. Exécutez cette commande pour installer cette boîte :
```Shell
vagrant box add <box-name> https://github.com/TICHANE-JM/Outils-Devops/blob/main/Vagrant/AWS/vagrant-aws-master/dummy.box
```

2. Installer le fournisseur AWS Vagrant en exécutant `vagrant plugin install vagrant*aws`.

3. Placez les fichiers du répertoire `vagrant-aws` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel (à l'aide de `git clone`), télécharger un fichier ZIP de l'intégralité du référentiel ou simplement télécharger les fichiers spécifiques çà partir du dossier `vagrant-aws` .

4. Modifiez `instances.yml` pour fournir les informations correctes à utiliser par Vagrant lors du lancement d'une instance sur AWS. Vous devrez spécifier le type d'unstance, la région, l'ID d'AMI, l'utilisateur SSH par défaut pour l'AMI, une liste de groupes de sécurité (par nom, et __non__ par ID de groupe de sécurité) et le nom de la paire de clés.

5. Dans une fenêtre de terminal, définissez les variables d'environnement `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` sur respectivement votre ID de clé d'accès AWS et votre clé d'accès secrète AWS.

6. Dans le répertoire où vous avez placé les fichiers de ce référentiel GitHub, exécutez `vagrant up` pour que Vagrant s'authentifie auprès d'AWS et lance l'instance souhaitée pour vous. Une fois l'instance créée, vous pouvez utiliser `vagrant ssh`pour vous connecter à l'instance et `vagrant destroy`(détruire) l'instance AWS pour vous. (Vous pouvez suivre toutes ces actions dans AWS Management Console, so vous le souhaitez).


Amusez-vous bien !!

## A noter :

Attention on ne créera qu'une seule instance sur AWS avec Vagrant. Un environnement permettant de faire tourner plusieurs instances est dans un autre répertoire.
