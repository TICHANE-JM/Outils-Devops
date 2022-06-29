# Exécution d'un cluster etcd v3 sur Ubuntu 16.04 sur AWS

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Terraform et Ansible pour configurer un cluster etcd v3 sur AWS.

## Contenu

* **ansible.cfg**: Ce fichier de configuration fournit des paramètres pour Ansible. Aucune modification de ce fichier ne devrait être nécessaire.

* **data.tf**: Ce fichier Terraform fournit certaines informations nécessaires à la configuration globale de Terraform (identifiants AMI, principalement). Aucune modification de ce fichier ne devrait être nécessaire.

* **ec2.ini**: Ce fichier de configuration contrôle le module d'inventaire dynamique EC2 pour Ansible. La seule modification apportée à ce fichier serait de spécifier la région AWS que vous utilisez (si ce n'est pas "us-west-2").

* **ec2.py**: Il s'agit du module d'inventaire dynamique EC2 utilisé par Ansible.

* **etcd.conf.j2**: Ce modèle Jinja2 est utilisé pour créer un fichier d'environnement pour configurer etcd. Aucune modification de ce fichier ne devrait être nécessaire.

* **etcd.service:** Il s'agit d'un fichier d'unité systemd pour etcd. Aucune modification de ce fichier ne devrait être nécessaire.

* **etcd.yml**: Il s'agit du playbook Ansible qui configurera les instances EC2 créées par Terraform pour exécuter etcd. Aucune modification de ce fichier ne devrait être nécessaire.

* **main.tf**: Ce fichier Terraform appelle deux autres modules Terraform (qui se trouvent dans `modules/vpc` et `modules/instance-cluster`) pour lancer des instances EC2 dans un nouveau VPC et les configurer avec des groupes de sécurité pour autoriser le trafic etcd. Aucune modification de ce fichier ne devrait être nécessaire.

* **provider.tf**: Ce fichier Terraform configure le fournisseur AWS. Aucune modification de ce fichier ne devrait être nécessaire.

* **README.md**: Ce fichier que vous lisez actuellement.

* **variables.tf**: Ce fichier Terraform définit les variables que Terraform attend de l'utilisateur (soit via la ligne de commande, soit via un fichier `*.tfvars`). Aucune modification de ce fichier ne devrait être nécessaire.

## Instructions

Ces instructions supposent que Terraform, Ansible et l'AWS CLI sont déjà installés et fonctionnent correctement.

1. Placez les fichiers du répertoire `etcdv3-ansible-aws-tf` de ce référentiel GitHub (le référentiel "TICHANE-JM/Outils-Devops") dans un répertoire de votre système. Vous pouvez cloner l'intégralité du référentiel "Outils-Devops" (à l'aide de `git clone`) ou simplement télécharger les fichiers spécifiques à partir du répertoire `etcdv3-ansible-aws-tf`.

2. Créez un fichier `terraform.tfvars` qui définit les variables "user_region", "node_type" et "key_pair". Si vous ignorez cette étape, vous devez fournir ces variables via la ligne de commande lors de l'exécution d'autres commandes `terraform`.

3. Exécutez `terraform init` pour charger les modules et vous assurer que le fournisseur AWS a été téléchargé et est disponible.

4. Exécutez `terraform plan` pour planifier ce que Terraform va faire.

5. Exécutez `terraform apply` pour que Terraform crée l'infrastructure spécifiée.

6. Exécutez `ansible-playbook etcd.yml` pour qu'Ansible configure les instances EC2 créées par Terraform pour exécuter etcd.

7. Une fois l'étape 6 terminée, vous pouvez tester etcd en vous connectant à l'une des instances via SSH et en exécutant cette commande :

		etcdctl member list
	
	Cela devrait renvoyer une liste de trois nœuds en tant que membres du cluster etcd. Si vous recevez une erreur ou si vous ne voyez pas les trois machines virtuelles répertoriées, détruisez l'environnement avec `terraform destroy` et recréez l'environnement à partir de zéro. Si vous continuez à rencontrer des problèmes, ouvrez un problème dans le référentiel "learning-tools" sur GitHub (ou déposez une demande d'extraction résolvant le problème).

8. Lorsque vous avez terminé avec l'environnement, lancez `terraform destroy` pour tout détruire.

Eclatez-vous !!!
