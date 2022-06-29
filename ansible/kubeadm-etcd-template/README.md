# Utilisation d'Ansible pour modéliser un fichier de configuration Kubeadm avec le support etcd

Ces fichiers fournissent un exemple d'utilisation du module `template` d'Ansible pour créer un fichier de configuration Kubeadm 1.11 (avec prise en charge locale d'etcd) à partir d'un modèle Jinja2. Le modèle et le playbook Ansible ont été testés avec Ansible 2.5 sur Fedora 27, mais devraient fonctionner sur n'importe quelle version récente d'Ansible sur n'importe quelle plate-forme prise en charge.

**REMARQUE:** À l'heure actuelle, les fichiers de configuration `kubeadm` générés par ce playbook n'ont _pas_ été vérifiés pour créer un cluster Kubernetes fonctionnel et conforme. Considérez-les comme uniquement à des fins de démonstration.

## Contenu

* **1-kubeadm.conf.j2**: Ce modèle Jinja2 contient le cadre d'un fichier de configuration Kubeadm. Ce modèle est pour le premier maître empilé.

* **2-kubeadm.conf.j2**: Ce modèle Jinja2 contient le cadre d'un fichier de configuration Kubeadm. Ce modèle est pour le deuxième maître empilé.

* **3-kubeadm.conf.j2**: Ce modèle Jinja2 contient le cadre d'un fichier de configuration Kubeadm. Ce modèle est pour le troisième maître empilé.

* **ansible.cfg**: Il s'agit d'un fichier de configuration Ansible. Vous devrez peut-être modifier ce fichier en fonction des systèmes cibles que vous utilisez avec cet environnement.

* **README.md**: Le fichier que vous êtes en train de lire.

* **template.yml**: Ce playbook Ansible prend une série de variables avec les modèles Jinja2 `*-kubeadm.conf.j2`. Le résultat est trois fichiers de configuration `kubeadm` différents.

## Instructions

Ces instructions supposent qu'Ansible est installé et fonctionne correctement sur votre système.

1. Placez les fichiers du répertoire `ansible/kubeadm-etcd-template` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel "Outils-Devops" (à l'aide de `git clone`) ou simplement télécharger les fichiers spécifiques à partir du dossier `ansible/kubeadm-etcd-template`.

2. (Facultatif) Modifiez `template.yml` pour spécifier différentes valeurs pour les variables définies dans le playbook.

3. Cet environnement a été testé à l'aide d'une AMI basée sur CentOS exécutée sur AWS et, à ce titre, utilise le module d'inventaire dynamique EC2. Modifiez `inventory/ec2.ini` et `inventory/hosts` selon vos besoins pour vous assurer que cet environnement fonctionnera pour votre inventaire spécifique. Vous devrez peut-être également modifier `ansible.cfg`, selon la distribution Linux que vous choisissez d'utiliser.

4. Exécutez `ansible-playbook template.yml` pour générer les trois différents fichiers de configuration `kubeadm`. Ils seront rendus dans le même répertoire que `kubeadm-cfg-first.yaml`, `kubeadm-cfg-second.yaml` et `kubeadm-cfg-third.yaml`, respectivement.

Eclatez-vous !!

## License

Ce contenu est sous licence MIT.
