# Machine Linux avec disques de données vides
Ce scénario créera une machine Ubuntu 16.04 avec des disques de données attachés à la machine virtuelle.

Pour plus d'informations sur ce scénario, voir [Comment attacher un disque de données à une machine virtuelle Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/classic/attach-disk)

Avant de tenter ce scénario, assurez-vous d'avoir suivi les [getting started docs](../../README.md#getting-started).

*Remarque : la prise en charge des disques de données est en préversion et sera probablement modifiée avant de devenir stable*

## Vagrant up
- Dans ce répertoire, exécutez ce qui suit
  ```bash
  vagrant up --provider=azure
  ```
- Le fichier Vagrant spécifie sur le disque de données nommé foo. Le disque foo n'est pas formaté, ni monté. Si vous souhaitez utiliser le disque, vous devrez formater et monter le lecteur. Pour obtenir des instructions sur la façon de procéder, voir : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/classic/attach-disk#initialize-a-new-data-disk-in- linux.
  Dans la prochaine version des disques de données, nous nous occuperons du montage et du formatage.

  
pour nettoyer, exécutez `vagrant destroy`
