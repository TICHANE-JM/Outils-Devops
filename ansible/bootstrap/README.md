# Utiliser Ansible pour Bootstrap Ansible

Ces fichiers fournissent un exemple d'utilisation d'Ansible pour amorcer des systèmes sur lesquels les dépendances Python nécessaires ne sont pas installées pour une prise en charge complète d'Ansible. Un exemple est Ubuntu 16.04, qui ne prend pas en charge Python 2.

## Contenu

* **ansible.cfg**: ce fichier indique à Ansible où trouver les informations d'inventaire par défaut (il exploite un script d'inventaire dynamique pour AWS).

* **bootstrap.yml**: ce playbook Ansible utilise le module `raw` pour installer la prise en charge de Python 2, qui à son tour permettra une prise en charge complète d'Ansible.

* **compute.tf**: Il s'agit d'une configuration Terraform qui lance une instance Ubuntu 16.04 sur AWS.

* **datasources.tf**: cette configuration Terraform recherche l'ID AMI pour Ubuntu 16.04 et le transmet à `compute.tf`.

* **ec2.ini**: Ce fichier est le fichier de configuration du script d'inventaire dynamique. Modifiez la ligne `regions=` dans ce fichier pour spécifier les régions AWS dans lesquelles les instances peuvent être exécutées.

* **ec2.py**: Il s'agit d'un script d'inventaire dynamique pour interroger les API AWS et générer un inventaire qu'Ansible peut utiliser. Aucune modification n'est nécessaire pour ce fichier.

* **provider.tf**: ce fichier configure le fournisseur AWS pour Terraform.

* **README.md**: Le fichier que vous êtes en train de lire.

* **variables.tf**: Ce fichier définit les variables que Terraform s'attend à avoir fournies (soit via un fichier `terraform.tfvars` soit via la ligne de commande `terraform` ).

## Instructions

Ces instructions supposent que vous disposez d'un compte AWS, que vous connaissez votre ID de clé d'accès AWS et votre clé d'accès secrète, et qu'Ansible et Terraform sont installés et fonctionnent sur votre système. Les instructions supposent également que l'AWS CLI fonctionne correctement.

1. Placez les fichiers du répertoire de ce référentiel GitHub `ansible/boostrap` dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel "Outils-Devops" (à l'aide de  `git clone`) ou simplement télécharger les fichiers spécifiques à partir du dossier `ansible/bootstrap`.

2. modifier `ec2.ini` et assurez-vous que la ligne "regions=" spécifie les régions AWS dans lesquelles vous allez lancer des instances.

3. Créer un fichier `terraform.tfvars` contenant les valeurs affectées aux variables répertoriées dans `variables.tf`.

4. Exécutez `terraform init`, suivi de `terraform plan` et `terraform apply` pour lancer une instance AWS dans la région que vous avez spécifiée.

5. Exécutez `ansible-playbook bootstrap.yml` pour lancer le playbook Ansible sur l'instance AWS lancée par Terraform.

    L'instance AWS doit maintenant avoir les dépendances Python nécessaires installées pour prendre en charge tous les modules et fonctionnalités Ansible. Eclatez-vous!

6. Exécutez `terraform destroy` pour démonter l'instance AWS que vous avez lancée à l'étape 4.

## License

Ce contenu est sous licence MIT.
