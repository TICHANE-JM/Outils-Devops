# Cluster Kubernetes local avec Kubeadm

Ces fichiers ont été créés pour permettre aux utilisateurs d'utiliser Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) rapidement et relativement facilement pour lancer un cluster Kubernetes local qui est amorcé à l'aide de `kubeadm`.

## Contenu

* **ansible.cfg**: Ce fichier de configuration Ansible configure Ansible pour une utilisation avec cet environnement Vagrant. Aucune modification de ce fichier ne devrait être nécessaire.

* **machines.yml**: Ce fichier YAML contient une liste de définitions de VM. Il est référencé par `Vagrantfile` lorsque Vagrant instancie les VM. Vous devrez modifier ce fichier pour fournir les noms de boîte Vagrant corrects. D'autres modifications ne devraient pas être nécessaires.

* **provision.yml**: Ce playbook Ansible configure les machines virtuelles avec les référentiels de packages nécessaires et installe les packages prérequis. Aucune modification de ce fichier ne devrait être nécessaire.

* **README.md**: Ce fichier que vous lisez actuellement.

* **Vagrantfile**: Ce fichier est utilisé par Vagrant pour faire tourner les machines virtuelles. Ce fichier est assez largement commenté pour aider à expliquer ce qui se passe. Vous devriez pouvoir utiliser ce fichier tel quel ; toutes les options de configuration de la machine virtuelle sont stockées en dehors de ce fichier.

## Instructions

Ces instructions supposent que vous avez déjà installé votre fournisseur de virtualisation (VMware Fusion/Workstation ou VirtualBox), Vagrant et tous les plug-ins nécessaires (tels que le plug-in Vagrant VMware). Reportez-vous à la documentation de ces produits pour plus d'informations sur l'installation ou la configuration.

1. Utilisez `vagrant box add` pour installer une boîte de base Ubuntu 16.04. Passez en revue `machines.yml` pour quelques boîtes suggérées pour Libvirt, VirtualBox et les plates-formes de virtualisation VMware.

2. Si le nom de votre boîte de base Ubuntu 16.04 n'est _pas_ l'un de ceux répertoriés dans `machines.yml`, modifiez `machines.yml` pour fournir le ou les noms de boîte corrects. Ce fichier comporte des lignes distinctes pour chaque fournisseur ; assurez-vous de modifier la ligne correcte pour votre fournisseur ("lv" est pour Libvirt, "vb" est pour VirtualBox et "vmw" est pour VMware).

3. Placez les fichiers du répertoire `kubernetes/kubeadm-vagrant` de ce référentiel GitHub dans un répertoire sur votre système local. Vous pouvez cloner l'intégralité du référentiel "Outils-Devops" (à l'aide de `git clone`) ou simplement télécharger les fichiers spécifiques à partir du dossier `kubernetes/kubeadm-vagrant`.

4. Exécutez `vagrant up` pour instancier 3 machines virtuelles --- un gestionnaire et deux nœuds. Toutes les machines virtuelles exécuteront Ubuntu 16.04.

5. Une fois Vagrant terminé, utilisez `vagrant ssh master` pour vous connecter à la machine virtuelle du gestionnaire.

6. Une fois connecté à "master", exécutez la commande suivante pour démarrer l'amorçage de votre cluster Kubernetes :

        kubeadm init --apiserver-advertise-address 192.168.100.100 \
        --feature-gates CoreDNS=true DynamicKubeletConfig=true \
        SelfHosting=true --pod-network-cidr 172.24.0.0/16

7. Une fois la commande terminée, suivez les étapes répertoriées pour installer un fichier de configuration pour `kubelet`.

8. Copiez la sortie finale de la commande `kubeadm init`, qui inclut un jeton, dans le presse-papiers. Vous en aurez besoin plus tard.

9. Les trois machines virtuelles ont toutes deux cartes réseau et nous voulons nous assurer que tous les services Kubernetes s'exécutent sur la deuxième carte réseau (enp0s8 sur Ubuntu 16.04). C'est celui connecté au réseau privé 192.168.100.0/24. Pour vous en assurer, connectez-vous à chaque nœud (par exemple, `vagrant ssh master`). En tant que root, éditez le fichier `/etc/default/kubelet` et ajoutez `--node-ip=$ipaddr` à la ligne `KUBELET_EXTRA_ARGS=`, où `$ipaddr` est l'adresse IP attribuée à la deuxième carte réseau. Rechargez ensuite les démons et redémarrez le service kubelet. Les commandes suivantes le feront (n'oubliez pas de les exécuter en tant que root, et assurez-vous également de les exécuter sur les trois nœuds) :

        eth1="enp0s8"
        ipaddr=$(ip a show $eth1 | egrep -o '([0-9]*\.){3}[0-9]*' | head -n1)
        sed -i "s/KUBELET_EXTRA_ARGS=/KUBELET_EXTRA_ARGS=--node-ip=$ipaddr/" /etc/default/kubelet
        systemctl daemon-reload && systemctl restart kubelet

10. Installez un plug-in CNI, tel que Calico (voir [https://docs.projectcalico.org/v3.3/getting-started/kubernetes/](https://docs.projectcalico.org/v3.3/getting-started /kubernetes/))

        kubectl apply -f \
        https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/etcd.yaml
        kubectl apply -f \
        https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/rbac.yaml
        kubectl apply -f \
        https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/calico.yaml

11. Déconnectez-vous et exécutez `vagrant ssh node-01` pour vous connecter à "node-01". Exécutez la commande `kubeadm join` que vous avez copiée à partir de la sortie sur "master".

12. Répétez l'étape 10, mais sur "node-02".

Eclatez-vous !!
