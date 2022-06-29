# Ansible

Ce dossier contient des outils, des ressources et des exemples pour vous aider à utiliser Ansible dans une variété d'environnements et pour une variété de cas d'utilisation.

## Contenu

**ansible-aws**: Cet ensemble de fichiers montre comment utiliser Ansible pour provisionner l'infrastructure sur AWS et comment mettre hors service (démanteler) cette même infrastructure.

**bootstrap**: Ce dossier contient des fichiers qui montrent comment utiliser Ansible pour "amorcer" un nœud Ubuntu 16.04 avec le support Python nécessaire afin de pouvoir exécuter des modules/playbooks Ansible supplémentaires.

**extract-gh-archive**: Ce dossier contient un environnement Vagrant + Ansible qui illustre quelques techniques d'utilisation d'Ansible pour télécharger une version binaire de GitHub, l'extraire dans un répertoire temporaire, copier le ou les fichiers pertinents, puis nettoyer.

**golang-role:** Ce répertoire contient un simple rôle Ansible pour installer Go sur un système Linux.

**kubeadm-etcd-template**: Ce dossier contient des exemples de modèles Jinja2 et un playbook Ansible pour générer des fichiers de configuration `kubeadm` pour générer un cluster etcd.

**kubeadm-template**: Dans ce dossier se trouvent un exemple de modèle Jinja2 et un playbook Ansible qui fournissent un exemple de création d'un fichier de configuration Kubeadm basé sur un modèle.

**pulumi-env**: Ce dossier contient un rôle Ansible pour configurer un environnement de travail Pulumi.

**src-dst-list**: Cet ensemble de fichiers montre comment utiliser des listes complexes avec la construction "with_items" d'Ansible. Cela vous permet de spécifier, par exemple, à la fois la source et l'emplacement d'une tâche de "copie" dans un seul bloc (lorsque la source et la destination varient d'un élément à l'autre).

**wireguard**: Ce dossier fournit un playbook qui effectue une installation très basique de Wireguard.

Eclatez-vous !!
