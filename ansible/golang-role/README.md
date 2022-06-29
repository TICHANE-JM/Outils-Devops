# Installer Go sous Linux

Ce répertoire contient un simple rôle Ansible pour installer Go sur un système Linux. Il a été testé avec Debian 10.4 et Ubuntu 18.04, mais devrait fonctionner avec à peu près n'importe quelle distribution Linux.

## Contenu

* **tasks/main.yml:** Celui-ci contient la liste des tâches Ansible à effectuer lorsque le rôle est exécuté.

* **vars/main.yml:** Celui-ci contient des variables pour le rôle.

## Instructions

Copiez simplement le contenu de ce répertoire dans l'emplacement correct pour vos rôles Ansible (cela variera en fonction du cas d'utilisation), puis incluez le rôle dans votre playbook Ansible.

## Plus d'information

* Le rôle par défaut est d'installer Go 1.15.2. Vous pouvez changer la version en changeant la valeur de la variable `golang_version` dans `vars/main.yml`.
* Le rôle par défaut consiste à installer Go dans le répertoire `/usr/local/go`. Vous pouvez modifier le préfixe (par exemple, pour installer sur `/opt/go`) en changeant la valeur de la variable `golang_install_path` dans `vars/main.yml`.
* Le rôle télécharge l'archive d'installation de Go dans `/usr/local/src/go<version>/` (en créant ce répertoire si nécessaire), et si l'archive existe déjà, il ne la téléchargera plus.
* Si `/usr/local/go/bin/go` existe, le rôle n'extrairea pas l'archive d'installation de Go pour installer Go. Si vous avez modifié la variable `golang_install_path`, le rôle l'utilise pour vérifier la présence du binaire Go.
