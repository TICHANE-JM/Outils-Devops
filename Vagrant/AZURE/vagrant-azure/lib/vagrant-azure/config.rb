# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'vagrant'
require 'haikunator'
require 'vagrant-azure/util/managed_image_helper'

module VagrantPlugins
  module Azure
    class Config < Vagrant.plugin('2', :config)
      include VagrantPlugins::Azure::Util::ManagedImagedHelper

      # ID de locataire Azure Active Directory -- ENV['AZURE_TENANT_ID']
      #
      # @return [String]
      attr_accessor :tenant_id

      # L'ID client de l'application Azure Active Directory -- ENV['AZURE_CLIENT_ID']
      #
      # @return [String]
      attr_accessor :client_id

      # Le secret du client d'application Azure Active Directory -- ENV['AZURE_CLIENT_SECRET']
      #
      # @return [String]
      attr_accessor :client_secret

      # L'ID d'abonnement Azure à utiliser -- ENV['AZURE_SUBSCRIPTION_ID']
      #
      # @return [String]
      attr_accessor :subscription_id

      # (Facultatif) Nom du groupe de ressources à utiliser.
      #
      # @return [String]
      attr_accessor :resource_group_name

      # (Facultatif) Emplacement Azure pour créer la machine virtuelle – par défaut, "westus"
      #
      # @return [String]
      attr_accessor :location

      # (Facultatif) Nom de la machine virtuelle
      #
      # @return [String]
      attr_accessor :vm_name

      # (Facultatif) Préfixe du nom DNS de la machine virtuelle
      # Utilise la valeur de vm_name si elle n'est pas spécifiée.
      # Remarque : ceci doit être conforme à l'expression régulière suivante :
      #
      #    ^[a-z][a-z0-9-]{1,61}[a-z0-9]
      #
      # Par conséquent, ce champ doit être défini si vm_name a des majuscules (par ex.)
      #
      # @return [String]
      attr_accessor :dns_name

      # (Facultatif) Préfixe du nom du groupe de sécurité réseau de la machine virtuelle
      #
      # @return [String]
      attr_accessor :nsg_name

      # Mot de passe pour la machine virtuelle -- Ceci n'est pas recommandé pour les déploiements *nix
      #
      # @return [String]
      attr_accessor :vm_password

      # (Facultatif) Taille de machine virtuelle à utiliser – par défaut, "Standard_D1". Voir : https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/
      #
      # @return [String]
      attr_accessor :vm_size

      # (Facultatif) Type de compte de stockage à utiliser : par défaut, "Premium_LRS". La valeur alternative est 'Standard_LRS' Voir : https://docs.microsoft.com/en-us/azure/storage/storage-about-disks-and-vhds-linux
      #
      # @return [String]
      attr_accessor :vm_storage_account_type

      # (Facultatif) Nom de l'URN de l'image de la machine virtuelle à utiliser -- la valeur par défaut est 'canonical:ubuntuserver:16.04.0-DAILY-LTS:latest'. Voir : https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-cli-ps-findimage/
      #
      # @return [String]
      attr_accessor :vm_image_urn

      # (Optional) URI d'image de système d'exploitation personnalisé (comme : http://mystorage1.blob.core.windows.net/vhds/myosdisk1.vhd) - néant par défaut.
      #
      # @return [String]
      attr_accessor :vm_vhd_uri

      # (Facultatif) L'ID d'image gérée qui sera utilisé pour créer la machine virtuelle
      # (comme : /subscriptions/{sub_id}/resourceGroups/{group_name}/providers/Microsoft.Compute/images/{image_name}) - néant par défaut
      #
      # @return [String]
      attr_accessor :vm_managed_image_id

      # (Facultatif sauf si vous utilisez une image personnalisée) Système d'exploitation de l'image personnalisée
      #
      # @return [String] "Linux" or "Windows"
      attr_accessor :vm_operating_system

      # (Facultatif) Tableau de disques de données à attacher à la VM
      #
      # exemple de création d'un disque de données vide
      #     {
      #         name: "mydatadisk1",
      #         size_gb: 30
      #     }
      #
      # exemple de connexion d'un VHD existant en tant que disque de données
      #     {
      #         name: "mydatadisk2",
      #         vhd_uri: "http://mystorage.blob.core.windows.net/vhds/mydatadisk2.vhd"
      #     },
      #
      # exemple de connexion d'un disque de données à partir d'une image
      #     {
      #         name: "mydatadisk3",
      #         vhd_uri: "http://mystorage.blob.core.windows.net/vhds/mydatadisk3.vhd",
      #         image: "http: //storagename.blob.core.windows.net/vhds/VMImageName-datadisk.vhd"
      #     }
      #
      # @return [Array]
      attr_accessor :data_disks

      # (Optional) Name of the virtual network resource
      #
      # @return [String]
      attr_accessor :virtual_network_name

      # (Optional) Name of the virtual network subnet resource
      #
      # @return [String]
      attr_accessor :subnet_name

      # (Optional) TCP endpoints to open up for the VM
      #
      # @return [String]
      attr_accessor :tcp_endpoints

      # (Optional) Name of the virtual machine image
      #
      # @return [String]
      attr_accessor :availability_set_name

      # (Optional) The timeout to wait for an instance to become ready -- default 120 seconds.
      #
      # @return [Fixnum]
      attr_accessor :instance_ready_timeout

      # (Optional) The interval to wait for checking an instance's state -- default 2 seconds.
      #
      # @return [Fixnum]
      attr_accessor :instance_check_interval

      # (Optional) The Azure Management API endpoint -- default 'https://management.azure.com' seconds -- ENV['AZURE_MANAGEMENT_ENDPOINT'].
      #
      # @return [String]
      attr_accessor :endpoint

      # (Optional - requrired for Windows) The admin username for Windows templates -- ENV['AZURE_VM_ADMIN_USERNAME']
      #
      # @return [String]
      attr_accessor :admin_username

      # (Optional - Required for Windows) The admin username for Windows templates -- ENV['AZURE_VM_ADMIN_PASSWORD']
      #
      # @return [String]
      attr_accessor :admin_password

      # (Optional) Whether to automatically install a self-signed cert and open the firewall port for winrm over https -- default true
      #
      # @return [Bool]
      attr_accessor :winrm_install_self_signed_cert

      # (Optional - Required for Windows) The admin username for Windows templates -- ENV['AZURE_VM_ADMIN_PASSWORD']
      #
      # @return [String]
      attr_accessor :deployment_template

      # (Optional) Wait for all resources to be deleted prior to completing Vagrant destroy -- default false.
      #
      # @return [String]
      attr_accessor :wait_for_destroy


      def initialize
        @tenant_id = UNSET_VALUE
        @client_id = UNSET_VALUE
        @client_secret = UNSET_VALUE
        @endpoint = UNSET_VALUE
        @subscription_id = UNSET_VALUE
        @resource_group_name = UNSET_VALUE
        @location = UNSET_VALUE
        @vm_name = UNSET_VALUE
        @vm_password = UNSET_VALUE
        @vm_image_urn = UNSET_VALUE
        @vm_vhd_uri = UNSET_VALUE
        @vm_image_reference_id = UNSET_VALUE
        @vm_operating_system = UNSET_VALUE
        @vm_managed_image_id = UNSET_VALUE
        @data_disks = UNSET_VALUE
        @virtual_network_name = UNSET_VALUE
        @subnet_name = UNSET_VALUE
        @dsn_name = UNSET_VALUE
        @nsg_name = UNSET_VALUE
        @tcp_endpoints = UNSET_VALUE
        @vm_size = UNSET_VALUE
        @vm_storage_account_type = UNSET_VALUE
        @availability_set_name = UNSET_VALUE
        @instance_ready_timeout = UNSET_VALUE
        @instance_check_interval = UNSET_VALUE
        @admin_username = UNSET_VALUE
        @admin_password = UNSET_VALUE
        @winrm_install_self_signed_cert = UNSET_VALUE
        @deployment_template = UNSET_VALUE
        @wait_for_destroy = UNSET_VALUE
      end

      def finalize!
        @endpoint = (ENV['AZURE_MANAGEMENT_ENDPOINT'] || 'https://management.azure.com') if @endpoint == UNSET_VALUE
        @subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] if @subscription_id == UNSET_VALUE
        @tenant_id = ENV['AZURE_TENANT_ID'] if @tenant_id == UNSET_VALUE
        @client_id = ENV['AZURE_CLIENT_ID'] if @client_id == UNSET_VALUE
        @client_secret = ENV['AZURE_CLIENT_SECRET'] if @client_secret == UNSET_VALUE


        @resource_group_name = Haikunator.haikunate(100) if @resource_group_name == UNSET_VALUE
        @vm_name = Haikunator.haikunate(100) if @vm_name == UNSET_VALUE
        @vm_size = 'Standard_DS2_v2' if @vm_size == UNSET_VALUE
        @vm_password = nil if @vm_password == UNSET_VALUE
        @vm_image_urn = 'canonical:ubuntuserver:16.04.0-LTS:latest' if @vm_image_urn == UNSET_VALUE
        @vm_vhd_uri = nil if @vm_vhd_uri == UNSET_VALUE
        @vm_vhd_storage_account_id = nil if @vm_vhd_storage_account_id == UNSET_VALUE
        @vm_operating_system = nil if @vm_operating_system == UNSET_VALUE
        @vm_managed_image_id = nil if @vm_managed_image_id == UNSET_VALUE
        @data_disks = [] if @data_disks == UNSET_VALUE

        @location = 'westus' if @location == UNSET_VALUE
        @virtual_network_name = nil if @virtual_network_name == UNSET_VALUE
        @subnet_name = nil if @subnet_name == UNSET_VALUE
        @dns_name = nil if @dns_name == UNSET_VALUE
        @nsg_name = nil if @nsg_name == UNSET_VALUE
        @tcp_endpoints = nil if @tcp_endpoints == UNSET_VALUE
        @vm_storage_account_type = 'Premium_LRS' if @vm_storage_account_type == UNSET_VALUE
        @availability_set_name = nil if @availability_set_name == UNSET_VALUE

        @instance_ready_timeout = 120 if @instance_ready_timeout == UNSET_VALUE
        @instance_check_interval = 2 if @instance_check_interval == UNSET_VALUE

        @admin_username = (ENV['AZURE_VM_ADMIN_USERNAME'] || 'vagrant') if @admin_username == UNSET_VALUE
        @admin_password = (ENV['AZURE_VM_ADMIN_PASSWORD'] || '$Vagrant(0)') if @admin_password == UNSET_VALUE
        @winrm_install_self_signed_cert = true if @winrm_install_self_signed_cert == UNSET_VALUE
        @wait_for_destroy = false if @wait_for_destroy == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        errors << I18n.t("vagrant_azure.custom_image_os_error") if !@vm_vhd_uri.nil? && @vm_operating_system.nil?
        errors << I18n.t("vagrant_azure.vhd_and_managed_image_error") if !@vm_vhd_uri.nil? && !@vm_managed_image_id.nil?
        errors << I18n.t("vagrant_azure.manage_image_id_format_error") if !@vm_managed_image_id.nil? && !valid_image_id?(@vm_managed_image_id)
        # Azure connection properties related validation.
        errors << I18n.t('vagrant_azure.subscription_id.required') if @subscription_id.nil?
        errors << I18n.t('vagrant_azure.mgmt_endpoint.required') if @endpoint.nil?
        errors << I18n.t('vagrant_azure.auth.required') if @tenant_id.nil? || @client_secret.nil? || @client_id.nil?

        { 'Microsoft Azure Provider' => errors }
      end
    end
  end
end
