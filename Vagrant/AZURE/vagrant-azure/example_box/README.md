# Boîte d'exemple Vagrant Azure

Ce répertoire contient l'exemple de contenu d'une boîte pour le fournisseur `azure`. Construisez ceci dans une boîte en utilisant :

Sous Windows :
```
C:\> bsdtar -cvzf azure.box metadata.json Vagrantfile
```

Sur * Nix :
```
$ tar cvzf azure.box ./metadata.json ./Vagrantfile
```

Vous pouvez ajouter toutes les valeurs par défaut prises en charge par le fournisseur ```azure``` au `Vagrantfile` dans votre boîte et le système de fusion intégré de Vagrant les définira comme valeurs par défaut. Les utilisateurs peuvent remplacer ces valeurs par défaut dans leurs propres Vagrantfiles.

Vous pouvez spécifier ici l'image à utiliser pour la VM via l'option ```vm_image``` Par exemple.,

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'azure'

  config.vm.provider :azure do |azure|
    azure.vm_image = 'NOM DE L'IMAGE A UTILISER'
  end
end
```

Voir également: [`Get-AzureVMImage`](http://msdn.microsoft.com/en-us/library/azure/dn495275.aspx)
