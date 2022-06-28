# encodage : utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'log4r'
require 'vagrant-azure/util/vm_status_translator'
require 'vagrant-azure/util/machine_id_helper'

module VagrantPlugins
  module Azure
    module Action
      class ReadState
        include VagrantPlugins::Azure::Util::VMStatusTranslator
        include VagrantPlugins::Azure::Util::MachineIdHelper

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::read_state')
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:azure_arm_service], env[:machine])
          @app.call(env)
        end

        def read_state(azure, machine)
          return :not_created if machine.id.nil?

          # Find the machine
          parsed = parse_machine_id(machine.id)
          vm = nil
          begin
            vm = azure.compute.virtual_machines.get(parsed[:group], parsed[:name], 'instanceView')
          rescue MsRestAzure::AzureOperationError => ex
            if vm.nil? || tearing_down?(vm.instance_view.statuses)
              # la machine ne peut pas être trouvée
              @logger.info('Machine introuvable ou arrêtée, en supposant qu'elle ait été détruite.')
              machine.id = nil
              return :not_created
            end
          end

          # Return the state
          power_state(vm.instance_view.statuses)
        end

      end
    end
  end
end
