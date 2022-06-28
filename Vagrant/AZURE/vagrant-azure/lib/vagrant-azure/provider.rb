# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'log4r'
require 'vagrant'

module VagrantPlugins
  module Azure
    class Provider < Vagrant.plugin('2', :provider)

      def initialize(machine)
        @machine = machine

        # Charger le pilote
        machine_id_changed

        # désactiver la fonctionnalité nfs par défaut, afin que la machine revienne à rsync par défaut
        @machine.config.nfs.functional = false
        @machine.config.winrm.password = @machine.provider_config.admin_password
        @machine.config.winrm.username = @machine.provider_config.admin_username
      end

      def action(name)
        # Essayez d'obtenir la méthode d'action de la classe Action
        # si elle existe, sinon retournez nil pour montrer que
        # nous ne supportons pas l'action donnée.
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        # Exécutez une action personnalisée appelée "read_ssh_info" qui 
        # fait ce qu'elle dit et place les informations SSH résultantes
        # dans la clé `:machine_ssh_info` de l'environnement.
        env = @machine.action('read_ssh_info')
        env[:machine_ssh_info]
      end

      def winrm_info
        env = @machine.action('read_winrm_info')
        env[:machine_winrm_info]
      end

      def state
        # Exécutez une action personnalisée que nous définissons appelée "read_state" qui fait ce 
        # qu'elle dit. Il place l'état dans la clé `: machine_state_id` dans l'environnement
        env = @machine.action('read_state')
        state_id = env[:machine_state_id]

        # Get the short and long description
        short = I18n.t("vagrant_azure.states.short_#{state_id}")
        long  = I18n.t("vagrant_azure.states.long_#{state_id}")

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? 'new' : @machine.id
        "Azure (#{id})"
      end
    end
  end
end
