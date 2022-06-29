# Utilisation d'Ansible pour modéliser un fichier de configuration Kubeadm

Ces fichiers fournissent un exemple d'utilisation du module `template` d'Ansible pour créer un fichier de configuration Kubeadm à partir d'un modèle Jinja2. Le modèle et le playbook Ansible ont été testés avec Ansible 2.5 sur Fedora 27, mais devraient fonctionner sur n'importe quelle version récente d'Ansible sur n'importe quelle plate-forme prise en charge.

**REMARQUE :** À l'heure actuelle, le fichier `kubeadm.conf` généré par ce playbook n'a _pas_ été vérifié pour créer un cluster Kubernetes fonctionnel et conforme. C'est uniquement à des fins de démonstration.

## Contenu

* **kubeadm.conf.j2**: Ce modèle Jinja2 contient le cadre d'un fichier de configuration Kubeadm.

* **README.md**: Le fichier que vous êtes en train de lire.

* **template.yml**: Ce playbook Ansible prend une série de variables avec le modèle Jinja2 `kubeadm.conf.j2` et génère un fichier de configuration Kubeadm.

## Instructions

Ces instructions supposent qu'Ansible est installé et fonctionne correctement sur votre système.

1. Placez les fichiers du répertoire `ansible/kubeadm-template` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel "outils-Devops" (à l'aide de `git clone`) ou simplement télécharger les fichiers spécifiques à partir du dossier `ansible/kubeadm-template`.

2. (Facultatif) Modifiez `template.yml` pour spécifier différentes valeurs pour les variables définies dans le playbook.

3. Exécutez `ansible-playbook -i "localhost," -c local template.yml` pour générer un fichier de configuration Kubeadm à partir du modèle. Le fichier généré résidera dans le même répertoire que `kubeadm.conf`.

Eclatez-vous !

## License

Ce contenu est sous licence MIT.
