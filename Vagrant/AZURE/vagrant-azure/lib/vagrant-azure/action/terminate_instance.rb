# encodage : utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'log4r'
require 'vagrant-azure/util/machine_id_helper'

module VagrantPlugins
  module Azure
    module Action
      class TerminateInstance
        include VagrantPlugins::Azure::Util::MachineIdHelper

        def initialize(app, _)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::terminate_instance')
        end

        def call(env)
          parsed = parse_machine_id(env[:machine].id)

          begin
            env[:ui].info(I18n.t('vagrant_azure.terminating', parsed))
            env[:ui].info('Deleting resource group')

            # Appelez la version begin_xxx_async pour lancer la suppression, mais n'attendez pas que le groupe de ressources soit nettoyé
            if env[:machine].provider_config.wait_for_destroy
              env[:azure_arm_service].resources.resource_groups.delete(parsed[:group])
            else
              env[:azure_arm_service].resources.resource_groups.begin_delete_async(parsed[:group]).value!
            end

            env[:ui].info('Resource group is deleting... Moving on.')
          rescue MsRestAzure::AzureOperationError => ex
            unless ex.response.status == 404
              raise ex
            end
          end
          env[:ui].info(I18n.t('vagrant_azure.terminated', parsed))

          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
