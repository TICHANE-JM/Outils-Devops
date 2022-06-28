# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'pathname'
require 'vagrant-azure/plugin'

module VagrantPlugins
  module Azure
    lib_path = Pathname.new(File.expand_path('../vagrant-azure', __FILE__))
    autoload :Action, lib_path.join('action')
    autoload :Errors, lib_path.join('errors')

    # Cela renvoie le chemin vers la source de ce plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
