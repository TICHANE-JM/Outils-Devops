# etcd Distributed Key-Value Store

Certains diront mais etcd Késako ?
[etcd](https://etcd.io/) (prononcer êt-si-di) est un magasin de données clé-valeur Open Source cohérent et distribué, qui stocke la configuration de systèmes ou clusters de machines distribués, coordonne leur planification et assure la découverte des services. etcd facilite et sécurise les mises à jour automatiques, coordonne la planification des tâches affectées aux hôtes et aide à la mise en place d'un réseau pour les conteneurs.

etcd est un élément essentiel de nombreux projets. Il s'agit surtout du magasin de données principal de Kubernetes, le système standard de choix pour l'orchestration des conteneurs. Grâce à etcd, les applications cloud-native sont davantage disponibles et restent fonctionnelles même en cas de défaillance d'un serveur. Les applications lisent et écrivent des données dans etcd. Ce magasin distribue ensuite les données de configuration afin d'assurer la redondance et la résilience de la configuration des nœuds.

**Kubernetes et etcd**
En tant que magasin de données principal de Kubernetes, etcd stocke et réplique tous les états des clusters Kubernetes. Comme il s'agit d'un composant essentiel d'un cluster Kubernetes, il est primordial qu'etcd adopte une approche fiable en ce qui concerne la configuration et la gestion du cluster.

etcd est un système distribué basé sur un consensus ; la configuration du cluster dans etcd peut donc s'avérer compliquée. L'amorçage, le maintien du quorum, la reconfiguration de l'appartenance au cluster, la création des sauvegardes, la gestion de la récupération après sinistre ainsi que la surveillance des événements critiques sont des tâches complexes et fastidieuses qui exigent un savoir-faire.

Tout ceci est facilité par l'utilisation de l'opérateur etcd.

Dans ce dossier se trouvent des environnements, des outils, des ressources, etc., pour en savoir plus sur etcd, le magasin clé-valeur distribué.
## Contenu

**etcd-2.0**: Utilisez le `Vagrantfile` et d'autres fichiers de ce répertoire pour activer un cluster etcd 2.0.9 exécuté sur Ubuntu 14.04. Le provisionnement est géré via des scripts shell.

**etcdv3-ansible-aws-tf**: Cet environnement exploite Terraform et Ansible pour créer un cluster etcd v3 sur Ubuntu 16.04 sur AWS.
