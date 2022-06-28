# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
begin
  require 'vagrant'
rescue LoadError
  raise 'Le plugin Vagrant Azure doit être exécuté dans Vagrant.'
end

# Il s'agit d'une vérification d'intégrité pour s'assurer que personne ne tente de l'installer
# dans une version antérieure de Vagrant.
if Vagrant::VERSION < '1.6.0'
  raise 'Le plugin Vagrant Azure n'est compatible qu'avec Vagrant 1.6+'
end

module VagrantPlugins
  module Azure
    class Plugin < Vagrant.plugin('2')
      name 'Azure'
      description <<-DESC
      Ce plugin installe un fournisseur qui permet à Vagrant de gérer
      des machines dans Microsoft Azure.
      DESC

      config(:azure, :provider) do
        require_relative 'config'
        Config
      end

      provider(:azure, parallel: true) do
        # Journalisation de la configuration et i18n
        setup_logging
        setup_i18n

        # Retourner le fournisseur
        require_relative 'provider'
        Provider
      end

      provider_capability(:azure, :winrm_info) do
        require_relative 'capabilities/winrm'
        VagrantPlugins::Azure::Cap::WinRM
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path(
          'locales/en.yml',
          Azure.source_root
        )
        I18n.load_path << File.expand_path(
          'templates/locales/en.yml',
          Vagrant.source_root
        )
        I18n.load_path << File.expand_path(
          'templates/locales/providers_hyperv.yml',
          Vagrant.source_root
        )
        I18n.reload!
      end

      def self.setup_logging
        require 'log4r'

        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          # Cela signifie que la constante de journalisation n'a pas été trouvée,
          # ce qui est bien. Nous gardons simplement `level` comme
          # `nil`. Mais nous disons à l'utilisateur.
          level = nil
        end

        # Certaines constantes, telles que "true" se résolvent en booléens, de sorte que la vérification
        # d'erreur ci-dessus ne l'attrape pas. Cela vérifiera que le niveau de
        # journalisation est un entier, comme l'exige Log4r.
        level = nil if !level.is_a?(Integer)

        # Définissez le niveau de journalisation sur tous les journaux d'espace de noms
        # "vagrant" tant que nous avons un niveau valide
        if level
          logger = Log4r::Logger.new('vagrant_azure')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
