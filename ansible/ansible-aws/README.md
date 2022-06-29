# Utiliser Ansible pour orchestrer AWS

Ces fichiers fournissent un exemple d'utilisation d'Ansible pour orchestrer des actions sur Amazon Web Services (AWS). 

## Contenu

* **ansible.cfg**: Ce fichier indique à Ansible où trouver le fichier d'inventaire par défaut (le fichier "inventaire" dans le même répertoire).

* **create.yml**: Ce playbook Ansible crée une infrastructure sur AWS. Assurez-vous de modifier ce fichier pour spécifier les valeurs répertoriées dans la section "vars" en haut du fichier.

* **delete.yml**: Ce playbook Ansible exploite le script d'inventaire dynamique "ec2.py" pour démonter (supprimer) l'infrastructure AWS. Assurez-vous de modifier ce fichier pour spécifier les valeurs dans les sections `vars` (une en haut et une plus bas).

* **ec2.ini**: Ce fichier est le fichier de configuration du script d'inventaire dynamique. Modifiez la ligne `regions=` dans ce fichier pour spécifier les régions AWS dans lesquelles les instances peuvent être exécutées.

* **ec2.py**: Il s'agit d'un script d'inventaire dynamique pour interroger les API AWS et générer un inventaire qu'Ansible peut utiliser. Aucune modification n'est nécessaire pour ce fichier.

* **inventory**: Il s'agit d'un simple fichier d'inventaire Ansible qui pointe vers l'hôte local. Il inclut une définition de "ansible_python_interpreter" pour aider à contourner les problèmes de Python virtualenv.

* **README.md**: Le fichier que vous êtes en train de lire.

## Instructions

Ces instructions supposent que vous disposez d'un compte AWS, que vous connaissez votre ID de clé d'accès AWS et votre clé d'accès secrète, et qu'Ansible est installé et fonctionne sur votre système.

1. Placez les fichiers du répertoire `ansible-aws` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel "Outils-Devops" (à l'aide de `git clone`) ou simplement télécharger les fichiers spécifiques à partir du dossier `ansible-aws`.

2. Modifiez `create.yml` et `delete.yml` pour spécifier les valeurs répertoriées dans la section `vars` de chaque fichier. Notez qu'il y a _deux_ sections `vars` dans `delete.yml` car il y a deux jeux dans le playbook.

3. Pour créer une infrastructure AWS à l'aide d'ansible, exécutez `ansible-playbook create.yml`.

4. Pour supprimer l'infrastructure créée à l'étape 3, exécutez `ansible-playbook -i ./ec2.py delete.yml`.

Eclatez-vous !!

## License

Ce contenu est sous licence MIT.
