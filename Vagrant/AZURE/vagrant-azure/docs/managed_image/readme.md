# Machine Ubuntu à partir d'une image gérée capturée
Ce scénario créera une machine à partir d'une image gérée capturée. Nous allons créer une machine virtuelle avec Azure CLI, capturer une image de la machine virtuelle et utiliser cette référence d'image pour une nouvelle machine Vagrant.

Pour voir plus d'informations sur ce scénario, voir [Créer une machine virtuelle à partir de l'image capturée](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/capture-image#step-3-create-a-vm-from-the-captured-image)

Avant de tenter ce scénario, assurez-vous d'avoir suivi les [documents de démarrage](../../README.md#getting-started).

## Vagrant up
Nous allons configurer cela avec Azure CLI, puis exécuter Vagrant après avoir provisionné les ressources Azure nécessaires.
- Connectez-vous à Azure CLI (si vous n'êtes pas déjà connecté)
  ```bash
  az login
  ```
- Créez un groupe de ressources pour vos VHD (en supposant que Westus)
  ```bash
  az group create -n vagrant -l westus
  ```
- Créer une nouvelle machine virtuelle
  ```bash
  az vm create -g vagrant -n vagrant-box --admin-username deploy --image UbuntuLTS
  ```
- Capturer une image de la VM
  ```bash
  az vm deallocate -g vagrant -n vagrant-box
  az vm generalize -g vagrant -n vagrant-box
  az image create -g vagrant --name vagrant-box-image --source vagrant-box
  ```
 Vous devriez voir la sortie json de la commande `az image create`. Extrayez la valeur "id" ci-dessous pour l'utiliser dans votre Vagrantfile.
  ```json
    {
      "id": "/subscriptions/XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX/resourceGroups/vagrant/providers/Microsoft.Compute/images/vagrant-box-image",
      "location": "westus",
      "name": "vagrant-box-image",
      "provisioningState": "Succeeded",
      "resourceGroup": "vagrant",
      "sourceVirtualMachine": {
        "id": "/subscriptions/XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX/resourceGroups/vagrant-test/providers/Microsoft.Compute/virtualMachines/vagrant-box",
        "resourceGroup": "vagrant"
      },
      "storageProfile": {
        "dataDisks": [],
        "osDisk": {
          "blobUri": null,
          "caching": "ReadWrite",
          "diskSizeGb": null,
          "managedDisk": {
            "id": "/subscriptions/XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX/resourceGroups/vagrant-test/providers/Microsoft.Compute/disks/osdisk_5ZglGr7Rj4",
            "resourceGroup": "vagrant"
          },
          "osState": "Generalized",
          "osType": "Linux",
          "snapshot": null
        }
      },
      "tags": null,
      "type": "Microsoft.Compute/images"
    }
  ```
- Mettez à jour le Vagrantfile dans ce répertoire avec l'URI de votre ressource d'image gérée (`azure.vm_managed_image_id`).
- Vagrant up
  ```bash
  vagrant up --provider=azure
  ```
  
Pour nettoyer, exécutez `vagrant destroy`
