## 1.0.5 (09 May 2014)

CARACTÉRISTIQUES

- Provision pour Windows VM.
- La machine virtuelle Windows doit être spécifiquement mentionnée dans le fichier Vagrant avec `config.vm.guest = :windows`
- Provisionnement de Chef, Puppet et Shell pour Linux et Windows VM.
- **Dossiers synchronisés**
- Linux VM utilise `rsync` et a été mentionné dans le VagrantFile.
- La machine virtuelle Windows utilisera par défaut PowerShell pour copier les fichiers.

AMÉLIORATIONS

  - Meilleure gestion des exceptions lorsque la VM ne parvient pas à être créée dans le cloud.
  - Meilleure gestion des exceptions pour les erreurs de session WinRM.

CORRECTIFS

  - Correction de quelques fautes de frappe dans README
  - Compatible avec Vagrant 1.6 [GH-15]

## Précédent
Voir les commits git
