# Fournisseur AWS Vagrant

Il s'agit d'un plugin [Vagrant](http://www.vagrantup.com) 1.2+ qui ajoute un fournisseur [AWS](http://aws.amazon.com) à Vagrant, il permet à Vagrant de contrôler et de fournir des machines dans EC2 et VPC.

**REMARQUE :** Ce plugin nécessite Vagrant 1.2+,

## Fonctionnalités

* Démarrez les instances EC2 ou VPC.
* SSH dans les instances.
* Provisionnez les instances avec n'importe quel provisionneur Vagrant intégré.
* Prise en charge minimale des dossiers synchronisés via `rsync`.
* Définissez des configurations spécifiques à une région afin que Vagrant puisse gérer des machines dans plusieurs régions.
* Regroupez les instances en cours d'exécution dans de nouvelles boîtes conviviales pour vagrant-aws

## Utilisation

Installez en utilisant les méthodes d'installation standard du plug-in Vagrant 1.1+. Après
installation, "vagrant up" et spécifiez le fournisseur "aws". Un exemple est
indiqué ci-dessous.

```
$ vagrant plugin install vagrant-aws
...
$ vagrant up --provider=aws
...
```

Bien sûr, avant de faire cela, vous devrez obtenir un fichier de boîte pour Vagrant compatible avec AWS .

## Démarrage rapide

Après avoir installé le plugin (instructions ci-dessus), le moyen le plus rapide de commencer est d'utiliser une boîte AWS factice et de spécifier tous les détails manuellement dans un bloc `config.vm.provider`. Alors d'abord, ajoutez la boîte factice en utilisant le nom que vous voulez :

```
$ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
...
```

Et puis créez un Vagrantfile qui ressemble à ce qui suit, en remplissant vos informations si nécessaire.

```
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "YOUR KEY"
    aws.secret_access_key = "YOUR SECRET KEY"
    aws.session_token = "SESSION TOKEN"
    aws.keypair_name = "KEYPAIR NAME"

    aws.ami = "ami-7747d01e"

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "PATH TO YOUR PRIVATE KEY"
  end
end
```

Et puis lancez `vagrant up --provider=aws`.

Cela démarrera une instance Ubuntu 12.04 dans la région us-east-1 de votre compte. Et en supposant que vos informations SSH ont été correctement renseignées dans votre Vagrantfile, SSH et le provisionnement fonctionneront également.

Notez que normalement une grande partie de ce passe-partout est encodé dans le fichier de boîte, mais le fichier de boîte utilisé pour le démarrage rapide, la boîte "fictive", n'a pas de valeurs par défaut préconfigurées.

Si vous rencontrez des problèmes avec la connexion SSH, assurez-vous que les instances sont lancées avec un groupe de sécurité qui autorise l'accès SSH.

Remarque : si vous ne configurez pas `aws.access_key_id` ou `aws_secret_access_key`, il tentera d'abord de lire les informations d'identification à partir des variables d'environnement, puis à partir de `$HOME/.aws/`. Vous pouvez choisir votre profil AWS et l'emplacement des fichiers en utilisant `aws.aws_profile` et `aws.aws_dir`, cependant les variables d'environnement auront toujours la priorité comme défini par la [documentation AWS](http://docs.aws.amazon.com /cli/latest/userguide/cli-chap-getting-started.html).
Pour utiliser le profil `vagrantDev` à partir de vos fichiers AWS :
```ruby
  # cette première ligne peut en fait être omise
  aws.aws_dir = ENV['HOME'] + "/.aws/"
  aws.aws_profile = "vagrantDev"
```


## Format de boîte

Chaque fournisseur de Vagrant doit introduire un format de boîte personnalisé. Ce fournisseur introduit les boîtes `aws`. Vous pouvez afficher un exemple de boîte dans le répertoire [example_box/](https://github.com/mitchellh/vagrant-aws/tree/master/example_box).
Ce répertoire contient également des instructions sur la façon de construire une boîte.
Le format de la boîte est essentiellement le fichier `metadata.json` requis avec un `Vagrantfile` qui définit les paramètres par défaut pour la configuration spécifique au fournisseur pour ce fournisseur.

## Configuration

Ce fournisseur expose un certain nombre d'options de configuration spécifiques au fournisseur :

* `access_key_id` - La clé d'accès pour accéder à AWS
* `ami` - L'identifiant AMI pour démarrer, tel que "ami-12345678"
* `availability_zone` - La zone de disponibilité dans la région pour lancer l'instance. Si nul, il utilisera la valeur par défaut définie par Amazon.
* `aws_profile` - Profil AWS dans vos fichiers de configuration. La valeur par défaut est *par défaut*.
* `aws_dir` - Emplacement de la configuration et des informations d'identification AWS. Par défaut, *$HOME/.aws/*.
* `instance_ready_timeout` - Le nombre de secondes à attendre pour que l'instance soit "prête" dans AWS. Par défaut à 120 secondes.
* `instance_check_interval` - Le nombre de secondes à attendre pour vérifier l'état de l'instance
* `instance_package_timeout` - Le nombre de secondes à attendre pour que l'instance soit gravée dans une AMI lors de l'empaquetage. Par défaut à 600 secondes.
* `instance_type` - Le type d'instance, tel que "m3.medium". La valeur par défaut de ceci, si elle n'est pas spécifiée, est "m3.medium". "m1.small" a été déprécié dans "us-east-1" et "m3.medium" est le plus petit type d'instance pour prendre en charge à la fois la paravirtualisation et les AMI hvm
* `keypair_name` - Nom de la paire de clés à utiliser pour amorcer les AMI qui la prennent en charge.
* `monitoring` - Définissez sur "true" pour permettre une surveillance détaillée.
* `session_token` - Le jeton de session fourni par STS
* `private_ip_address` - L'adresse IP privée à attribuer à une instance au sein d'un [VPC](http://aws.amazon.com/vpc/)
* `elastic_ip` - Peut être défini sur "true" ou sur une adresse IP Elastic existante. Si true, allouez une nouvelle adresse IP Elastic à l'instance. S'il est défini sur une adresse IP Elastic existante, attribuez l'adresse à l'instance.
* `region` - La région dans laquelle démarrer l'instance, par exemple "us-east-1"
* `secret_access_key` - La clé d'accès secrète pour accéder à AWS
* `security_groups` - Un tableau de groupes de sécurité pour l'instance. Si cette instance est lancée dans VPC, il doit s'agir d'une liste de nom de groupe de sécurité. Pour un VPC autre que celui par défaut, vous devez utiliser des ID de groupe de sécurité à la place (http://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html).
* `iam_instance_profile_arn` - Le nom de ressource Amazon (ARN) du profil d'instance IAM à associer à l'instance
* `iam_instance_profile_name` - Le nom du profil d'instance IAM à associer à l'instance
* `subnet_id` - Le sous-réseau dans lequel démarrer l'instance, pour VPC.
* `associate_public_ip` - Si vrai, associera une adresse IP publique à une instance dans un VPC.
* `ssh_host_attribute` - Si `:public_ip_address`, `:dns_name` ou `:private_ip_address`, utilisera l'adresse IP publique, le nom DNS ou l'adresse IP privée, respectivement, pour SSH à l'instance. Par défaut, Vagrant utilise le premier d'entre eux (dans cet ordre) connu. Cependant, cela peut entraîner des problèmes de connexion si, par exemple, vous attribuez une adresse IP publique mais que vos groupes de sécurité empêchent l'accès SSH public et vous obligent à vous connecter via l'adresse IP privée ; spécifiez `: adresse_ip_privée` dans ce cas.
* `tenancy` - Lors de l'exécution dans un VPC, configurez la location de l'instance. Prend en charge « par défaut » et « dédié ».
* `tags` - Un hachage de balises à définir sur la machine.
* `package_tags` - Un hachage de balises à définir sur l'ami généré lors de l'opération de package.
* `use_iam_profile` - Si vrai, utilisera les [profils IAM](http://docs.aws.amazon.com/IAM/latest/UserGuide/instance-profiles.html) pour les informations d'identification.
* `block_device_mapping` - Propriété de mappage de périphérique de bloc Amazon EC2
* `elb` - Le nom ELB à attacher à l'instance.
* `unregister_elb_from_az` - Supprime l'ELB de l'AZ lors de la suppression de la dernière instance si vrai (par défaut). Dans un VPC autre que celui par défaut, cela doit être faux.
* `terminate_on_shutdown` - Indique si une instance s'arrête ou se termine lorsque vous lancez l'arrêt à partir de l'instance.
* `endpoint` - L'URL du point de terminaison pour la connexion à AWS (ou à un service de type AWS). Requis uniquement pour les clouds non AWS, tels que [eucalyptus](https://github.com/eucalyptus/eucalyptus/wiki).

Ceux-ci peuvent être définis comme une configuration typique spécifique au fournisseur :

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :aws do |aws|
    aws.access_key_id = "foo"
    aws.secret_access_key = "bar"
  end
end
```

Notez que vous n'avez pas besoin de coder en dur votre `aws.access_key_id` ou `aws.secret_access_key` car ils seront récupérés à partir des variables d'environnement `AWS_ACCESS_KEY` et `AWS_SECRET_KEY`.

En plus des configurations de niveau supérieur ci-dessus, vous pouvez utiliser la méthode `region_config` pour spécifier des remplacements spécifiques à la région dans votre Vagrantfile. Notez que la configuration `region` de niveau supérieur doit toujours être spécifiée pour choisir la région que vous souhaitez utiliser, cependant. Cela ressemble à ceci :

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :aws do |aws|
    aws.access_key_id = "foo"
    aws.secret_access_key = "bar"
    aws.region = "us-east-1"

    # Simple region config
    aws.region_config "us-east-1", :ami => "ami-12345678"

    # More comprehensive region config
    aws.region_config "us-west-2" do |region|
      region.ami = "ami-87654321"
      region.keypair_name = "company-west"
    end
  end
end
```

Les configurations spécifiques à la région remplaceront les configurations de niveau supérieur lorsque cette région est utilisée. Sinon, ils héritent des configurations de niveau supérieur, comme vous vous en doutez probablement.

## Réseaux

Les fonctionnalités de mise en réseau sous la forme de `config.vm.network` ne sont pas prises en charge avec `vagrant-aws`, actuellement. Si l'un d'entre eux est spécifié, Vagrant émettra un avertissement, mais démarrera sinon la machine AWS.

## Dossiers synchronisés

La prise en charge des dossiers synchronisés est minimale. Lors de `vagrant up`, `vagrant reload` et `vagrant provision`, le fournisseur AWS utilisera `rsync` (si disponible) pour synchroniser de manière unidirectionnelle le dossier avec la machine distante via SSH.

Voir [Dossiers Vagrant Synced : rsync](https://docs.vagrantup.com/v2/synced-folders/rsync.html)


## Autres exemples

### Balises (Tags)

Pour utiliser des balises, définissez simplement un hachage de clé/valeur pour les balises que vous souhaitez associer à votre instance, comme :

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider "aws" do |aws|
    aws.tags = {
	  'Name' => 'Some Name',
	  'Some Key' => 'Some Value'
    }
  end
end
```

### Données d'utilisateur

Vous pouvez spécifier des données utilisateur pour l'instance en cours de démarrage.

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider "aws" do |aws|
    # Option 1: a single string
    aws.user_data = "#!/bin/bash\necho 'got user data' > /tmp/user_data.log\necho"

    # Option 2: use a file
    aws.user_data = File.read("user_data.txt")
  end
end
```

### Taille du disque

Besoin de plus d'espace sur votre disque d'instance ? Augmentez la taille du disque.

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider "aws" do |aws|
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 50 }]
  end
end
```

### ELB (équilibreurs de charge élastiques)

Vous pouvez automatiquement attacher une instance à un ELB lors du démarrage et la détacher lors de la destruction.

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider "aws" do |aws|
    aws.elb = "production-web"
  end
end
```

## Développement

Pour travailler sur le plug-in `vagrant-aws`, clonez ce référentiel et utilisez [Bundler](http://gembundler.com) pour obtenir les dépendances :

```
$ bundle
```

Une fois que vous avez les dépendances, vérifiez que les tests unitaires réussissent avec `rake` :

```
$ bundle exec rake
```

Si ceux-ci réussissent, vous êtes prêt à commencer à développer le plugin. Vous pouvez tester le plugin sans l'installer dans votre environnement Vagrant en créant simplement un `Vagrantfile` au niveau supérieur de ce répertoire (il est gitignored) et en ajoutant la ligne suivante à votre `Vagrantfile`

```ruby
Vagrant.require_plugin "vagrant-aws"
```
Use bundler to execute Vagrant:
```
$ bundle exec vagrant up --provider=aws
```

