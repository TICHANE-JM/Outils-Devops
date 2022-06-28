# Documents de scénario Vagrant Azure
Vous trouverez ici quelques scénarios courants d'utilisation du plug-in Azure pour Vagrant.

## Conditions préalables
Avant de tenter un scénario, assurez-vous d'avoir suivi les [docs de démarrage] (../readme.md#getting-started).

## Scénarios

### [Basic Linux Setup](./basic_linux)
Configurer une simple machine Ubuntu 16.04

### [Basic Windows Setup](./basic_windows)
Configurer une machine Windows SQL Server 2016

### [Ubuntu Xenial Machine from VHD](./custom_vhd)
Configurer une boîte Ubuntu à partir d'un VHD personnalisé

### [Managed Image Reference](./managed_image)
Configurez une machine virtuelle à partir d'une référence d'image gérée capturée à partir d'une machine virtuelle Azure créée précédemment.

### [Data Disks (empty disk)](./data_disks)
Configurer une boîte Ubuntu avec un disque attaché vide

## Boîtes Azure

Le plugin vagrant-azure offre la possibilité d'utiliser des boîtes ```Azure``` avec Vagrant. Veuillez consulter l'exemple de boîte fourni dans le répertoire [example_box(https://github.com/azure/vagrant-azure/tree/v2.0/example_box) et suivez les instructions qui s'y trouvent pour créer une boîte `azure` .

Pour la documentation générale de Vagrant, voir [Vagrant Docs](http://docs.vagrantup.com/v2/).
