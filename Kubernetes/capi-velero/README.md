# Infrastructure pour les tests CAPI-Velero

Ce référentiel contient les fichiers nécessaires pour créer un environnement permettant de tester l'utilisation de [Velero](https://velero.io) avec [l'API Cluster](https://cluster-api.sigs.k8s.io). Ceci inclut une configuration [Terraform](https://terraform.io) pour créer l'infrastructure AWS requise et des fichiers de configuration `kubeadm` pour amorcer les instances résultantes dans un cluster [Kubernetes](https://kubernetes.io).

## Prérequis / Hypothèses

* Ce référentiel et ces instructions supposent la présence de rôles et de stratégies IAM qui activent le fournisseur de cloud AWS. 

## Instructions

1. Créez un fichier `terraform.tfvars` en utilisant le fichier `terraform.tfvars.example` inclus comme exemple.
2. Vérifiez les valeurs par défaut dans `variables.tf` et remplacez-les, si nécessaire, par des valeurs supplémentaires dans le fichier `terraform.tfvars` créé à l'étape 1.
3. Passez en revue le profil d'instance IAM spécifié dans `instances.tf` et assurez-vous que les noms correspondent aux noms des profils d'instance IAM de votre compte AWS qui activent/prennent en charge le fournisseur de cloud AWS.
4. Exécutez `terraform plan` et examinez le résultat.
5. Si le résultat de l'étape 4 est acceptable, exécutez `terraform apply` pour créer l'infrastructure.
6. À l'aide de SSH, connectez-vous à chacune des instances créées à l'étape 4 et assurez-vous que le nom d'hôte local correspond à l'entrée EC2 Private DNS. En exécutant `sudo hostnamectl set-hostname $(curl -s http://169.254.169.254/latest/meta-data/local-hostname)` on s'assurera que le nom d'hôte est correctement défini. (Notez que l'accès SSH se fait via un hôte bastion, donc une configuration SSH locale peut être nécessaire.)
7. Une fois les étapes 5 et 6 terminées, utilisez  `terraform output` pour personnaliser le fichier `kubeadm-cp-mgmt-a.yaml` Plus précisément, modifiez la valeur de la ligne "controlPlaneEndpoint" pour refléter le nom DNS correct de l'équilibreur de charge créé pour le cluster "mgmt-a". Modifiez également la valeur du champ "name" sous "nodeRegistration" de `HOSTNAME` au nom d'hôte complet défini à l'étape 6.
8. Répétez l'étape 7, mais pour le fichier `kubeadm-cp-mgmt-b.yaml` et en utilisant le nom DNS correct de l'équilibreur de charge créé pour le cluster "mgmt-b".
9. Utilisez `rsync` ou `scp` pour copier les instances de plan de contrôle modifiées `kubeadm-cp-mgmt-a.yaml` et `kubeadm-cp-mgmt-b.yaml`vers les clusters « mgmt-a » et « mgmt-b », respectivement. Nommez les fichiers `kubeadm.yaml` sur les systèmes de destination.
10. Sur les instances du plan de contrôle pour les clusters "mgmt-a" et "mgmt-b" (vous pouvez utiliser `terraform output` pour obtenir les informations sur ces instances), exécutez `kubeadm init --config kubeadm.yaml`.
11. À l'aide des informations affichées par la commande `kubeadm init` sur chacun des nœuds du plan de contrôle, personnalisez les fichiers `kubeadm-wkr-mgmt-a.yaml` et `kubeadm-wkr-mgmt-b.yaml` Plus précisément, vous devrez fournir la valeur du jeton d'amorçage, le hachage SHA256 du certificat du plan de contrôle, le nom DNS du point de terminaison du plan de contrôle et le nom d'hôte du système (que, à l'étape 6, vous avez défini sur la même valeur comme l'entrée EC2 Private DNS).
12. Copiez les fichiers modifiés à l'étape 11 dans les instances de travail pour les clusters "mgmt-a" et "mgmt-b", respectivement. Nommez les fichiers `kubeadm.yaml` sur les systèmes de destination.
13. Sur chacune des instances de travail, exécutez `kubeadm join --config kubeadm.yaml`.
14. Lorsque l'étape 13 est terminée, installez un plug-in CNI. Reportez-vous à la documentation du plugin CNI pour plus de détails.

Une fois les étapes ci-dessus terminées, vous disposerez d'un cluster Kubernetes fonctionnel prêt à être transformé en un cluster de gestion d'API de cluster à l'aide de `clusterctl init`.  Ces clusters de gestion peuvent ensuite être utilisés pour tester l'utilisation de Velero pour la sauvegarde et la restauration des objets de l'API de cluster.
