# Ubuntu Xenial Machine de VHD
Ce scénario créera une image personnalisée à partir d'un VHD Ubuntu Xenial préparé. Cela créera une image gérée Azure à partir du VHD généralisé personnalisé. L'image managée Azure sera utilisée pour créer une nouvelle machine virtuelle Azure.

Pour voir plus d'informations sur ce scénario, voir [Préparer une machine virtuelle Ubuntu pour Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu)

Avant de tenter ce scénario, assurez-vous d'avoir suivi les [documents de démarrage] (../../README.md#getting-started).

Si vous souhaitez créer une image plus personnalisée, vous pouvez faire la même chose manuellement avec votre propre VHD en suivant ces [instructions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create -upload-ubuntu?toc=%2fazure%2fvirtual-machines%2flinux%2ftoc.json#manual-steps).

## Vagrant up
Nous allons configurer cela avec Azure CLI, puis exécuter Vagrant après avoir provisionné les ressources Azure nécessaires.
- Connectez-vous à Azure CLI (si vous n'êtes pas déjà connecté)
  ```bash
  az login
  ```
- Créez un groupe de ressources pour vos VHD (en supposant que Westus)
  ```bash
  az group create -n vagrantimages -l westus
  ```
- Créez un compte de stockage dans la région que vous souhaitez déployer
  ```bash
  # insérez votre propre nom pour le nom DNS du compte de stockage (-n)
  az storage account create -g vagrantimages -n vagrantimagesXXXX --sku Standard_LRS -l westus
  ```
- Téléchargez et décompressez le VHD d'Ubuntu
  ```bash
  wget -qO- -O tmp.zip http://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.vhd.zip && unzip tmp.zip && rm tmp.zip
  ```
- Chargez le VHD sur votre compte de stockage dans le conteneur vhds
  ```bash
  conn_string=$(az storage account show-connection-string -g vagrantimages -n vagrantimagesXXXX -o tsv)
  az storage container create -n vhds --connection-string $conn_string
  az storage container create -n vhds vagrantimagesXXXX
  az storage blob upload -c vhds -n xenial-server-cloudimg-amd64-disk1.vhd -f xenial-server-cloudimg-amd64-disk1.vhd --connection-string $conn_string
  ```
- Mettez à jour Vagrantfile avec l'URI de votre blob téléchargé (`azure.vm_vhd_uri`).
- Vagrant up
  ```bash
  vagrant up --provider=azure
  ```
  
Pour nettoyer, exécutez `vagrant destroy`
  
 
 
