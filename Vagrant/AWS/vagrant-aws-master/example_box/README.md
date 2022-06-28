# Boîte d'exemple AWS Vagrant

Les fournisseurs Vagrant nécessitent chacun un format de boîte personnalisé spécifique au fournisseur.
Ce dossier montre l'exemple de contenu d'une boîte pour le fournisseur `aws`.
Pour en faire une boîte :

```
$ tar cvzf aws.box ./metadata.json ./Vagrantfile
```

Cette boîte fonctionne en utilisant la fusion Vagrantfile intégrée de Vagrant pour configurer les valeurs par défaut pour AWS. Ces valeurs par défaut peuvent facilement être écrasées par des Vagrantfiles de niveau supérieur (tels que les Vagrantfiles racine du projet).
