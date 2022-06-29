# Utilisation de Kustomize avec les manifestes d'API de cluster

Comment peut on utiliser `kustomize`pour modifier les manifestes de l'[API de cluster](https://github.com/kubernetes-sigs/cluster-api). Il ne nécessite aucun "hack" comme ceux nécessaires pour utiliser `kustomize`avec`les fichiers de configuration `kubeadm`, 
mais similaire à la modification des fichiers de configuration `kubeadm`, vous devrez généralement utiliser la fonctionnalité de correction `kustomize`lorsque vous travaillez avec les manifeste de l'API de cluster.

## Cas d'utilisation fictif

Nous allons créer un cas d'utilisation fictif pour l'API Cluster `kustomize` :
1. Trois clusters différents sur AWS sont nécessaires. le cluster de gestion existe déjà.
2. Deux de ces clusters s'exacuteront dans la région AWS "us-west-2", tandis que le troisième s'exécutera dans la région "us-east-2".
3. L'un des deux clusters « us-west-2 » utilisera des types d'instances plus grands pour prendre en charge des charges de travail plus gourmandes en ressources.
4. Les trois clusters doivent être hautement disponibles, avec plusieurs nœuds de plan de contrôle.

Avec ce cas d'utilisation fictif en place, on est maintenant prêt à configurer une structure de répertoires pour prendre en charge l'utilisation de l'API de cluster `kustomize` .

## Configuration de la structure du répertoire.

Pour prendre en charge ce cas d'utilisation fictif, vous devrez utiliser une structure de répertoires prenant en charge l'utilisation de superpositions `kustomize`. Par conséquent, je proposerais une structure de répertoire qui ressemble à ceci :

```
(parent)
|- base
|- overlays
    |- usw2-cluster1
    |- usw2-cluster2
    |- use2-cluster1
```

Le répertoire `base` stockera le point de "départ" des manifestes d'API de cluster finaux, ainsi qu'un fichier `kustomization.yaml`qui identifie ces manifestes d'API de cluster en tant que ressources `kustomize` à utiliser.

Chacun des sous-répertoires de superposition aura également un fichier `kustomization.yaml`et divers fichiers de correctifs qui seront appliqués aux ressources de base pour produire les manifestes finaux.

## Création de la configuration de base

La configuration de base (qui se trouve dans le répertoire `base` de la structure de répertoire décrite ci-dessus) contiendra des configurations complètes, mais assez génériques, pour l'API Cluster :

* Définitions des objets Cluster et AWSCluster
* Définitions des objets Machine et AWSMachine pour le plan de contrôle avec les objets KubeadmConfig associés.
* Définitions des objets Machine, AWSMachineTemplate et KudeadmConfigTemplate) pour les noeuds de travail.

Pour faciliter le travail avec les superpositions `kustomize` , modifions les configurations de base pour s'adapter à la majorité de nos déploiements signifiera moins de correctifs nécessaires `kustomize` plus tard.
Dans ce scénario fictif, deux des clusters s'exécuteront dans "us-west-2", vous devez donc spécifier "us-west-2" comme région dans la configuration de base. De même, si vous prévoyez d'utiliser la même clé SSH pour tout les clusters (non recommandé), vous pouvez intégrer ce paramètre dans la configuration de base.

Un dernier élémént est nécessaire, et c'est un fichier `kustomization.yaml` dans le répertoire de base qui identifie les ressources disponibles pour `kustomize` . En supposant que vos fichiers ont été nommés `cluster.yaml` (pour les objets Cluster et AWSCluster), `controlplane.yaml` (pour les objets liés au plan de contrôle) et `workers.yaml` (pour les objets liés aux noeuds de travail), alors votre `kustomization.yaml`pourrait ressembler à ceci :

```
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - cluster.yaml
  - controlplane.yaml
  - workers.yaml
```

Une fois la configuration de base terminée, vous êtes maintenant prêt à passer aux superpositions.

## Création des superpositions

Les superpositions sont là où les choses commencent à devenir intéressantes. Chaque cluster aura son propre répertoire dans le répertoire `overlays` , où vous fournirez les correctifs spécifiques au cluster qui seront utilisés par  `kustomize`  pour générer le YAML pour ce cluster particulier.

Commençons par la superposition « usw2-cluster1 ». Pour comprendre ce qui sera nécessaire, vous devez d'abord comprendre quelles modifications doivent être apportées à la configuration de base pour produire la configuration souhaitée pour ce cluster particulier. Alors quels changements fallait-il apporter ?

1. Le `metadata.name` pour les objets Cluster et AWSCluster doit être modifié. Pour conserver le lien entre les objets Cluster et AWSCluster, le champ `spec.infrastructureRef.name` de l'objet Cluster doit être modifié pour utiliser la valeur correcte pointant vers l'objet AWSCluster.
2. Le champ `Spec.sshKeyName`de l'objet AWSCluster doit avoir le nom de clé SSH correct spécifié.
3. De même, le champ `metadata.name` pour les objets Machine, les objets AWSMachine et les objets KubeadmConfig doivent également être modifiés pour utiliser les noms corrects pour les objets du plan de contrôle et les objets du nœud de travail. Étant donné que le champ `metadata.name`est en cours de modification pour les objets AWSMachine et KubeadmConfig, vous devrez également mettre à jour les champs `spec.infrastructureRef.name` et `spec.bootstrap.configRef.name` de l'objet Machine, respectivement, avec les valeurs correctes.
4. Si vous utilisez plutôt un MachineDeployment pour les noeuds de travail, les champs `metadata.name` des objets MachineDeployement, AWSMachineTemplate et KubeadmConfigTemplate doivent être mis à jour. Comme pour le 3., les références dans les champs `spec.template.spec.bootstrap.configRef.name` et `spec.template.spec.infrastructureRef.name` doivent être mises à jour pour l'objet MachineDeployment. Enfin, le champ `spec.template.spec.sshKeyName` doit être mis à jour pour l'objet.
5. Toutes les balises (Tag) faisant référence au nom du cluster (telles que les balises affectées à tous les objets Machine, affectées à tous les objets MachineDeployment ou référencées dans le modèle de tous les objets MachineDeployement) doivent être mises à jour pour faire référence au nom de cluster correct. Cela inclurait également les balises dans le champ `spec.selector.matchLabels` d'un MachineDeployment.

Maintenant qu'on a une idée des modifications à apporter à un ensemble de manifestes d'API de cluster, explorons __comment__ nous pourrions procéder pour apporter ces modifications avec `kustomize` . Nous allons pas passer en revue tous les changements, mais plutôt illustrer quelques façons différentes donct ces changements pourront être mis en oeuvre.

## Utilisation des correctifs JSON

Une façon de corriger des champs individuels dans un manifeste consiste à utiliser les correctifs JSON 6902 (ainsi nommés car ils sont décrits dans [RFC 6902](https://tools.ietf.org/html/rfc6902) ). À titre d'exemple, j'explorerai l'utilisation des correctifs JSON 6902 pour l'adresse n° 1 de la liste des modifications décrites ci-dessus.

La première partie d'un correctif JSON 6902 est la référence au fichier de correctif lui-même qui doit être placé dans le fichier `kustomization.yaml` 

```
patchesJson6902:
  - target:
      group: cluster.x-k8s.io
      version: v1alpha2
      kind: Cluster
      name: capi-quickstart
    path: cluster-patch.json
```

Nous indiquons à `kustomize`où se trouve le fichier de correctif et sur quel(s) objet(s) il doit être appliqué. Etant donné que nous utilisons les manifestes du Quick Start CAPI comme configuration de base, vous pouvez voir que le correctif est spécifié pour fonctionner sur l'objet Cluster nommé "capi-quickstart".

La deuxième partie est le correctif lui-même, qui peut être formaté en YAML ou JSON. Nous utiliserons JSON dans cet exemple.

Voici un patch JSON 6902 encodé en JSON :

```
[
  { "op": "replace",
    "path": "/metadata/name",
    "value": "usw2-cluster-1" },
  { "op": "replace",
    "path": "/spec/infrastructureRef/name",
    "value": "usw2-cluster-1" }
]
```
(Cet exemple, ainsi que les autres exemples , sont écris pour des raisons de lisibilité ; il est parfaitement acceptable que chaque opération soit formatée sur une seule ligne.)

Dans cet exemple, les correctifs sont fournis dans une liste JSON (indiquée par des crochets) et chaque correctif est un objet JSON avec trois propriétés : `op` , `path` et `value` . Ce correctif apporte deux modifications au manifeste d'origine. Tout d'abord, il modifie le champ `metadata.name` pour utiliser "usw2-cluster1" comme valeur. deuxièmement, il modifie le champ `spec.infrastructureRef.name` pour utiliser également "usw2-cluster1" comme valeur.

Ce correctif traite l'objet Cluster, mais on doit également traiter l'objet AWSCluster. pour cela, on aura besoin d'un fichier de correctif séparé référencé par une section distincte dans `kustomization.yaml` .

Le code dans `kustomization.yaml` ressemblerait à ceci :

```
patchesJson6902:
  - target:
      group: infrastructure.cluster.x-k8s.io
      version: v1alpha2
      kind: AWSCluster
      name: capi-quickstart
    path: awscluster-patch.json
```
Et le fichier de correctif correspondant ressemblerait à ceci :

```
[
  { "op": "replace",
    "path": "/metadata/name",
    "value": "usw2-cluster-1" }
]
```

On notera que nous n'avons pas mentionné que le fichier `kustomization.yaml` de ce répertoire doit également avoir une référence à la configuration de base ; nous ne parlons que de la configuration du patch.

En supposant qu'un fichier correctement configuré `kustomization.yaml`se situe dans ce répertoire de superposition et fait référence à ces deux correctifs JSON 6902, exécutons `kustomize build` . Cette exécution générera un ensemble personnalisé de manifestes où les objets Cluster et AWSCluster auront des valeurs spécifiques pour ce cluster de charge de travail particulier.

Nous pouvons répliquer cette approche pour effectuer certaines des autres modifications répertoriées ci-dessus, mais dans certains cas, l'utilisation d'un correctif JSON 6902 peut ne pas être la méthode la plus efficace (cela est particulièrement vrai lorqu'un certain nombre de champs différents sont modifiés).

## Utilisation de correctifs de fusion stratégiques

Au lieu d'utiliser un correctif JSON 6902, l'autre alternative consiste à utiliser un correctif de fusion stratégique. Cela vous permet de modifier facilement un certain nombre de champs différents dans un seul manifeste en « remplaçant » les valeurs déjà présentes (le cas échéant).

Comme pour un patch JSON 6902, la première partie d'un patch de fusion stratégique consiste à ajouter une référence au fichier `kustomization.yaml` de l'overlay :

```
patches:
  - target:
      group: cluster.x-k8s.io
      version: v1alpha2
      kind: Machine
      name: .*
    path: machine-labels.yaml
```
Cela ressemble beaucoup à la référence montrée précédemment à un patch JSON 6902, mais dans ce cas, toute notre attention est portée sur le fait que cela utilise une expression régulière (regex) pour le champ `name`. Cela vous permet de créer un correctif qui s'appliquera à plusieurs objets (tant que les objets correspondent aux sélecteurs de groupe, de version et de genre). Dans cet exemple particulier, nous faisons référence à un patch qui doit s'appliquer à tous les objets Machine.

La deuxième partie est le correctif lui-même, qui est maintenant un fichier YAML qui contient les valeurs à remplacer dans la configuration de base ainsi que toutes les valeurs supplémentaires qui doivent être ajoutées à la configuration de base. Dans cet exemple, nous modifierons uniquement une valeur existante.

Voici le contenu du fichier de correctif référencé ci-dessus :
```
---
apiVersion: cluster.x-k8s.io/v1alpha2
kind: Machine
metadata:
  name: .*
  labels:
    cluster.x-k8s.io/cluster-name: "usw2-cluster1"
```

Ici encore, vous voyez l'utilisation d'une expression régulière pour capturer tous les objets Machine quel que soit leur nom, puis une valeur pour `labels` , cela écrasera (dans ce cas) la valeur existante dans la configuration de base. Si vous souhaitez ajouter des labels supplémentaires, vous pouvez simplement spécifier les labels supplémentaires ici même dans le patch. `kustomize` gérera alors le remplacement des valeurs existantes et l'ajout de nouvelles valeurs.

L'exécution de `kustomize build` avec ces changements entraînera la modification de tous les objets Machine pour utiliser le label spécifiée ci-dessus, qui fait partie du changement n ° 5 répertorié ci-dessus (notez que nous n'avons pas abordé les changements affectant l'utilisation d'un MachineDeployment, seuls les objets Machine individuels l'ont été) .

Cet exemple, cependant, n'illustre pas vraiment la différence entre un correctif JSON 6902 et une fusion stratégique de correctifs. Nous allons utiliser un autre exemple qui aborde le reste du changement n°5 en modifiant les labels d'un MachineDeployment.

Pour ce dernier exemple, on aura à nouveau besoin d'une référence au fichier de correctif dans `kustomization.yaml` ainsi que du fichier de correctif lui-même. on ne répètera pas tout ce qui est entré dans `kustomization.yaml` comme on l'a déjà vu plusieurs fois ; il ressemblera beaucoup à celui utilisé pour modifier les objets Machine, mais pointant plutôt vers les objets MachineDeployment.

Le correctif réel illustre mieux comment vous pouvez apporter plusieurs modifications à un manifeste de base avec un seul fichier de correctif :

```
---
apiVersion: MachineDeployment
kind: MachineDeployment
metadata:
  name: .*
  labels:
    cluster.x-k8s.io/cluster-name: "usw2-cluster1"
spec:
  selector:
    matchLabels:
        cluster.x-k8s.io/cluster-name: "usw2-cluster1"
  template:
    metadata:
      labels:
        cluster.x-k8s.io/cluster-name: "usw2-cluster1"
```
Ici, un seul fichier de correctif apporte trois modifications distinctes (mais liées) aux ressources MachineDeployment dans les manifestes de base. Dans ce cas, répliquer cette fonctionnalité avec un correctif JSON 6902 ne serait pas très difficile, mais les utilisateurs peuvent trouver la lisibilité de cette approche pour faciliter le raisonnement sur ce qu'il se passe avec `kustomize` quand il génère les manifestes.

Il existe un certain nombre d'autres changements qui seraient nécessaires pour mettre pleinement en œuvre le scénario fictif, mais dans un souci de brièveté (raisonnable), je n'inclurai ni ne décrirai tous les changements nécessaires .

## Ressources additionnelles

* **Répertoire overlays:**  Dans ce répertoire ce trouve trois autres répertoires de ce tutoriel (use2-cluster1 ; usw2-cluster1 ; usw2-cluster2 ) avec tout les fichiers qu'on a parlé à l'intérieur.
* **Répertoire base:** Dans ce répertoire se trouve tout les fichers `cluster.yaml` , `controlplane.yaml` , `kustomization.yaml` , `workers.yaml`

Eclatez-vous !!




