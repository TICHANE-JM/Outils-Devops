# Extraire et "installer" une archive de GitHub

Ces fichiers fournissent un exemple de téléchargement, d'extraction et "d'installation" d'une version binaire d'un projet open source à partir de GitHub. À titre d'exemple, le playbook montre comment procéder pour `ksonnet`, un projet open source lié à Kubernetes dirigé par Heptio.

## Contenu

* **machines.yml**: Ce fichier de données YAML est utilisé par Vagrant pour déterminer quelles images de machine virtuelle utiliser, combien de machines virtuelles créer et quelle devrait être la configuration de ces machines virtuelles.

* **provision.yml**: Ce playbook Ansible montre la création d'un répertoire temporaire, l'enregistrement de ce répertoire temporaire pour une utilisation ultérieure, puis le téléchargement, l'extraction et "l'installation" d'une version binaire.

* **README.md**: Le fichier que vous êtes en train de lire.

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les machines virtuelles. Aucune modification ne devrait être nécessaire dans ce fichier ; toutes les informations de configuration sont fournies dans `machines.yml`.

## Instructions

Ces instructions supposent que Vagrant et Ansible sont installés et fonctionnent correctement sur votre système, et que le fournisseur de virtualisation utilisé par Vagrant fonctionne comme prévu. Ces instructions supposent également que vous avez installé tous les plug-ins Vagrant nécessaires pour prendre en charge le fournisseur de virtualisation installé.

1. Placez les fichiers du répertoire `ansible/extract-gh-archive` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité de ce référentiel "Outils-Devops" (En utilisant `git clone`) ou téléchargez simplement les fichiers spécifiques à partir du dossier `ansible/extract-gh-archive`.

2. Installez une boîte Vagrant pour CentOS 7. Le fichier `machines.yml` contient des boîtes suggérées pour VirtualBox, VMware et Libvirt.

3. Exécutez "vagrant up" pour faire tourner la machine virtuelle Vagrant. Vagrant invoquera automatiquement Ansible. Ansible créera un répertoire temporaire, téléchargera la dernière archive de version `ksonnet` (au moment de la rédaction de cet article), l'extrairea et copiera le binaire `ks` dans une copie versionnée.

4. Utilisez `vagrant ssh` pour vous connecter à la machine virtuelle Vagrant et voir que `ks` est installé et dans le chemin. Appuyez sur Ctrl-D pour vous déconnecter lorsque vous avez terminé.

5. Exécutez "vagrant destroy" pour détruire l'environnement.

Eclatez-vous !!

## License

Ce contenu est sous licence MIT.
