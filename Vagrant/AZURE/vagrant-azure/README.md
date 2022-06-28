**ATTENTION :** Ce projet n'est plus soutenu. Le projet est archivé. Même s'il l'est, le plugin fonctionnera toujours comme il le fait actuellement. Cela ne devrait pas affecter les flux de travail utilisant actuellement vagrant-azure.
De nombreuses personnes utilisent activement ce plugin, mais souffrent depuis longtemps d'un manque de soutien dans ce projet. Nous aimerions encourager la communauté à créer ce projet et à travailler ensemble pour faire avancer et soutenir Vagrant sur Azure.

# Fournisseur Azure vagrant

[![Gem Version](https://badge.fury.io/rb/vagrant-azure.png)](https://rubygems.org/gems/vagrant-azure)

Il s'agit d'un plugin [Vagrant](http://www.vagrantup.com) 1.7.3+ qui ajoute le fournisseur [Microsoft Azure](https://azure.microsoft.com)
à Vagrant, permettant à Vagrant de contrôler et de provisionner des machines dans Microsoft Azure.

## Commencer

[Install Vagrant](https://www.vagrantup.com/docs/installation/)

### Créer une application Azure Active Directory (AAD)
AAD encourage l'utilisation d'Applications/Service Principals pour authentifier les applications. Une combinaison application/principal de service fournit une identité de service à Vagrant pour gérer votre abonnement Azure. [Cliquez ici pour en savoir plus sur les applications AAD et les principaux de service.](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-application-objects)
- [Installer l'interface de ligne de commande Azure](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- exécuter `az login` pour se connecter à Azure
- exécuter `az ad sp create-for-rbac` pour créer une application Azure Active Directory avec accès à Azure Resource Manager pour l'abonnement Azure actuel
  - Si vous souhaitez l'exécuter pour un autre abonnement Azure, exécutez `az account set --subscription 'your subscription name'`
- exécutez `az account list --query "[?isDefault].id" -o tsv` pour obtenir votre ID d'abonnement Azure.
  
La sortie de `az ad sp create-for-rbac` devrait ressembler à ceci :
```json
{
  "appId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "displayName": "some-display-name",
  "name": "http://azure-cli-2017-04-03-15-30-52",
  "password": "XXXXXXXXXXXXXXXXXXXX",
  "tenant": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}
```
Les valeurs `tenant`, `appId` et `password` correspondent aux valeurs de configuration 
`azure.tenant_id`, `azure.client_id` et `azure.client_secret` dans votre fichier Vagrant ou vos variables d'environnement.

Pour ***nix**, modifiez votre `Vagrantfile` comme indiqué ci-dessous et fournissez toutes les valeurs comme expliqué.

### Créer un fichier Vagrant

Créez un répertoire et ajoutez le contenu Linux ou Windows Vagrantfile ci-dessous à un fichier nommé `Vagrantfile`.

#### Linux Vagrantfile
```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'azure'

  # utiliser la clé ssh locale pour se connecter à la boîte de vagabondage distante
  config.ssh.private_key_path = '~/.ssh/id_rsa'
  config.vm.provider :azure do |azure, override|

    # chacune des valeurs ci-dessous utilisera par défaut les variables env nommées ci-dessous si elles ne sont pas spécifiées explicitement
    azure.tenant_id = ENV['AZURE_TENANT_ID']
    azure.client_id = ENV['AZURE_CLIENT_ID']
    azure.client_secret = ENV['AZURE_CLIENT_SECRET']
    azure.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']
  end

end
```

#### Windows Vagrantfile
```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'azure'

  config.vm.provider :azure do |azure, override|

    # chacune des valeurs ci-dessous utilisera par défaut les variables env nommées ci-dessous si elles ne sont pas spécifiées explicitement
    azure.tenant_id = ENV['AZURE_TENANT_ID']
    azure.client_id = ENV['AZURE_CLIENT_ID']
    azure.client_secret = ENV['AZURE_CLIENT_SECRET']
    azure.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']

    azure.vm_image_urn = 'MicrosoftSQLServer:SQL2016-WS2012R2:Express:latest'
    azure.instance_ready_timeout = 600
    azure.vm_password = 'TopSecretPassw0rd'
    azure.admin_username = "OctoAdmin"
    override.winrm.transport = :ssl
    override.winrm.port = 5986
    override.winrm.ssl_peer_verification = false # must be false if using a self signed cert
  end

end
```

### Faites tourner une boîte dans Azure

Installez le plugin vagrant-azure en utilisant les méthodes d'installation standard de Vagrant 1.1+. Après avoir installé le plugin, vous pouvez faire ```vagrant up``` et utiliser le fournisseur ```azure``` . Par exemple:

```sh
$ vagrant box add azure https://github.com/TICHANE-JM/Outils-Devops/edit/main/Vagrant/AZURE/vagrant-azure/dummy.box --provider azure
$ vagrant plugin install vagrant-azure
$ vagrant up --provider=azure
```

Cela fera apparaître une machine virtuelle Azure selon les options de configuration définies ci-dessus.

Vous pouvez maintenant utiliser SSH (s'il s'agit d'une machine virtuelle * Nix) en utilisant ```vagrant ssh```, RDP (s'il s'agit d'une machine virtuelle Windows) en utilisant ```vagrant rdp``` ou PowerShell ```vagrant powershell```.

Normalement, beaucoup d'options, par exemple, ```vm_image_urn```, seront intégrées dans un fichier boîte et vous n'aurez qu'à fournir un minimum d'options dans le fichier ```Vagrantfile```. Puisque nous utilisons une boîte factice, il n'y a pas de valeurs par défaut préconfigurées.

## Configuration

Le fournisseur vagrant-azure expose des options de configuration spécifiques à Azure :

### Paramètres obligatoires
* `tenant_id`: votre ID de locataire Azure Active Directory.
* `client_id`: votre ID client d'application Azure Active Directory.
* `client_secret`: la clé secrète de votre client d'application Azure Active Directory.
* `subscription_id`: ID d'abonnement Azure que vous souhaitez utiliser.
*Remarque : pour obtenir ces valeurs, consultez : Créer une application Azure Active Directory

### Paramètres de machine virtuelle facultatifs
* `vm_name`:  Nom de la machine virtuelle
* `vm_password`: (Facultatif pour *nix) Mot de passe pour la machine virtuelle -- Ceci n'est pas recommandé pour les déploiements *nix
* `vm_size`: taille de la machine virtuelle à utiliser -- par défaut, 'Standard_DS2_v2'. Voir les tailles pour [*nix](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/), [Windows](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sizes/).
* `admin_username`: Le nom d'utilisateur root/administrateur de la VM

### Paramètres d'image VM facultatifs
`vm_image_urn`, `vm_vhd_uri`, et `vm_managed_image_id` s'excluent mutuellement. Ils ne doivent pas être utilisés en combinaison.
* `vm_image_urn`: nom de l'urn de l'image de la machine virtuelle à utiliser -- la valeur par défaut est 'canonical:ubuntuserver:16.04-LTS:latest'. Voir la documentation pour [*nix](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-cli-ps-findimage/), [Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-cli-ps-findimage).
* `vm_vhd_uri`: URI vers le VHD personnalisé. Si le VHD n'est pas accessible au public, fournissez un jeton SAS dans l'URI.
    * `vm_operating_system`:  (Obligatoire) Doit fournir le système d'exploitation si vous utilisez une image personnalisée ("Linux" ou "Windows")
    * `vm_vhd_storage_account_id`: (Obligatoire) L'ID Azure Resource Manager du compte de stockage dans lequel l'image du système d'exploitation est stockée (par exemple : /subscriptions/{subscription id}/resourceGroups/{resource group}/providers/Microsoft.Storage/storageAccounts/{account name}).
* `vm_managed_image_id`: créez une machine virtuelle à partir d'une machine virtuelle généralisée qui est stockée en tant que disque géré ou non géré. Voir: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource

### Paramètres de disque de données VM facultatifs (préversion)
La fonctionnalité de disque de données est en préversion et peut changer avant la version 2.0.
* `data_disks`: (Facultatif) Tableau de disques de données à attacher à la VM. Pour plus d'informations sur la connexion du lecteur, voir : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/classic/attach-disk.
```ruby
override.data_disks = [
    # exemple de création d'un disque de données vide
    {
      name: "mydatadisk1", 
      size_gb: 30
    }
]
```

### Paramètres de mise en réseau facultatifs
* `virtual_network_name`: (Facultatif) Nom de la ressource réseau virtuelle
* `dns_name`: (Facultatif) Préfixe d'étiquette DNS
* `nsg_name`: (Facultatif) Préfixe d'étiquette de groupe de sécurité réseau
* `subnet_name`: (Facultatif) Nom de la ressource de sous-réseau du réseau virtuel
* `tcp_endpoints`: (Facultatif) Les règles de sécurité entrantes personnalisées font partie du groupe de sécurité réseau (c'est-à-dire les points de terminaison tcp ouverts). Permet de spécifier un ou plusieurs intervalles sous la forme de :
  * un tableau `['8000-9000', '9100-9200']`, 
  * un seul intervalle comme `'8000-9000'`,
  * un seul port comme `8000`.

### Paramètres Windows facultatifs
* `winrm_install_self_signed_cert`: (Facultatif, Windows uniquement) Indique s'il faut installer automatiquement un certificat auto-signé pour permettre à WinRM de communiquer via HTTPS (5986). Uniquement disponible lorsqu'un `deployment_template` personnalisé n'est pas fournie. 'vrai' par défaut.

### Paramètres de provisionnement facultatifs
* `instance_ready_timeout`: (Facultatif) Le délai d'attente pour qu'une instance soit prête -- 120 secondes par défaut.
* `instance_check_interval`: (Facultatif) L'intervalle d'attente pour vérifier l'état d'une instance -- 2 secondes par défaut.
* `wait_for_destroy`: (Facultatif) Attendez que toutes les ressources soient supprimées avant de terminer Vagrant destroy -- false par défaut.

### Paramètres Azure facultatifs
* `endpoint`: (Facultatif) Le point de terminaison de l'API de gestion Azure -- par défaut `ENV['AZURE_MANAGEMENT_ENDPOINT']` s'il existe, revient à <https://management.azure.com>.
* `resource_group_name`:  (Facultatif) Nom du groupe de ressources à utiliser.
* `location`: (Facultatif) Emplacement Azure pour créer la machine virtuelle -- par défaut à `westus`

## [Extended Documentation](./docs/)
Pour plus d'informations sur les scénarios courants et d'autres fonctionnalités, consultez la [documentation étendue](./docs/).

