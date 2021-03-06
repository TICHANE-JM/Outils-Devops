# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require_relative '../services/azure_resource_manager'
require 'log4r'

module VagrantPlugins
  module Azure
    module Action
      class ConnectAzure
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::connect_azure')
        end

        def call (env)
          if env[:azure_arm_service].nil?
            config = env[:machine].provider_config
            provider = MsRestAzure::ApplicationTokenProvider.new(config.tenant_id, config.client_id, config.client_secret)
            env[:azure_arm_service] = VagrantPlugins::Azure::Services::AzureResourceManager.new(provider, config.subscription_id)
          end

          @app.call(env)
        end
      end
    end
  end
end
