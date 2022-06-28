# encodage : utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'log4r'
require 'vagrant-azure/util/machine_id_helper'

module VagrantPlugins
  module Azure
    module Action
      class RestartVM
        include VagrantPlugins::Azure::Util::MachineIdHelper

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::restart_vm')
        end

        def call(env)
          parsed = parse_machine_id(env[:machine].id)
          env[:ui].info(I18n.t('vagrant_azure.restarting', parsed))
          env[:azure_arm_service].compute.virtual_machines.restart(parsed[:group], parsed[:name])
          env[:ui].info(I18n.t('vagrant_azure.restarted', parsed))
          @app.call(env)
        end
      end
    end
  end
end
