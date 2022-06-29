## Rôle Ansible pour un environnement Pulumi

Ce répertoire contient un rôle [Ansible](https://www.ansible.com/) pour configurer un environnement de travail pour [Pulumi](https://pulumi.io). L'utilisation de ce rôle permet aux utilisateurs de créer facilement des environnements de travail pour Pulumi à l'aide d'un hyperviseur local ou d'une instance cloud.

Pour utiliser ce rôle, ajoutez simplement le chemin d'accès au rôle dans la section `roles:` de votre playbook Ansible.

### Démarrer avec Pulumi

Pulumi est une infrastructure **moderne en tant que plate-forme de code** qui vous permet d'utiliser des langages de programmation et des outils familiers pour créer, déployer et gérer une infrastructure cloud.

Avec cet environnement on peut déployer une application simple dans un cloud  tel que :
* AWS
* Kubernetes
* Microsoft Azure
* Google Cloud

#### Service Pulumi
Le service Pulumi est un service entièrement géré qui vous aide à adopter facilement le SDK open source de Pulumi. Il fournit une gestion intégrée de l'état et des secrets, s'intègre au contrôle de source et CI/CD, et offre une console Web et une API qui facilitent la visualisation et la gestion de l'infrastructure. Il est gratuit pour une utilisation individuelle, avec des fonctionnalités disponibles pour les équipes.



