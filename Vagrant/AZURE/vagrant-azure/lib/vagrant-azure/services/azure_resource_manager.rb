# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.

require 'azure_mgmt_resources'
require 'azure_mgmt_compute'
require 'azure_mgmt_network'
require 'azure_mgmt_storage'
require 'vagrant-azure/version'

module VagrantPlugins
  module Azure
    module Services
      class AzureResourceManager

        TELEMETRY = "vagrant-azure/#{::VagrantPlugins::Azure::VERSION}"
        TENANT_ID_NAME = 'AZURE_TENANT_ID'
        CLIENT_ID_NAME = 'AZURE_CLIENT_ID'
        CLIENT_SECRET_NAME = 'AZURE_CLIENT_SECRET'

        # AzureResourceManager donne accès aux API Azure Resource Manager
        # @param [MsRest::TokenProvider] objet token_provider utilisé pour obtenir un jeton d'authentification auprès d'Azure Active
        #   Directory
        # @param [String] subscription_id
        # @param [String] base_url
        def initialize(token_provider, subscription_id, base_url = nil)
          @token_provider = if token_provider.nil? || !token_provider.is_a?(MsRest::TokenProvider)
                              if ENV[TENANT_ID_NAME].nil? || ENV[CLIENT_ID_NAME].nil? || ENV[CLIENT_SECRET_NAME].nil?
                                raise ArgumentError "Either set #{TENANT_ID_NAME}, #{CLIENT_ID_NAME} or #{CLIENT_SECRET_NAME} in your environment, or pass in a MsRest::TokenProvider"
                              else
                                MsRestAzure::ApplicationTokenProvider.new(
                                    ENV[TENANT_ID_NAME],
                                    ENV[CLIENT_ID_NAME],
                                    ENV[CLIENT_SECRET_NAME])
                              end
                            else
                              token_provider
                            end
          @credential = MsRest::TokenCredentials.new(token_provider)
          @base_url = base_url
          @subscription_id = subscription_id
        end

        # Client d'API de calcul Azure Resource Manager
        # @return [Azure::ARM::Compute::ComputeManagementClient]
        def compute
          build(::Azure::ARM::Compute::ComputeManagementClient)
        end

        # Client d'API de ressources génériques Azure Resource Manager
        # @return [Azure::ARM::Resources::ResourceManagementClient]
        def resources
          build(::Azure::ARM::Resources::ResourceManagementClient)
        end

        # Client d'API réseau Azure Resource Manager
        # @return [Azure::ARM::Network::NetworkManagementClient]
        def network
          build(::Azure::ARM::Network::NetworkManagementClient)
        end

        # Client d'API de stockage Azure Resource Manager
        # @return [Azure::ARM::Storage::StorageManagementClient]
        def storage
          build(::Azure::ARM::Storage::StorageManagementClient)
        end

        private

        def build(clazz)
          instance = clazz.new(*client_params)
          instance.subscription_id = @subscription_id
          instance.add_user_agent_information(TELEMETRY)
          instance
        end

        def client_params
          [@credential, @base_url].reject{ |i| i.nil? }
        end
      end
    end
  end
end
