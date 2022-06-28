# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'pathname'

require 'vagrant/action/builder'
require 'vagrant/action/builtin/wait_for_communicator'

module VagrantPlugins
  module Azure
    module Action
      # Incluez les modules intégrés afin que nous puissions les utiliser comme éléments de niveau supérieur.
      include Vagrant::Action::Builtin

      # Cette action est appelée pour arrêter la machine distante.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConnectAzure
            b2.use StopInstance
          end
        end
      end

      # Cette action est appelée pour arrêter la machine distante.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b2.use Call, IsCreated do |env2, b3|
                unless env2[:result]
                  b3.use MessageNotCreated
                  next
                end
                b3.use ConnectAzure
                b3.use TerminateInstance
                b3.use ProvisionerCleanup if defined?(ProvisionerCleanup)
              end
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      # Cette action est appelée lorsque `vagrant provision` est appelé.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Provision
          end
        end
      end

      # Cette action est appelée pour lire les informations SSH de la machine.
      # L'état résultant devrait être placé dans la clé `:machine_ssh_info`.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAzure
          b.use ReadSSHInfo
        end
      end

      # Cette action est appelée pour lire les informations WinRM de la machine. 
      # L'état résultant devrait être placé dans la clé `:machine_winrm_info`.
      def self.action_read_winrm_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAzure
          b.use ReadWinrmInfo
        end
      end

      # Cette action est appelée pour lire l'état de la machine. 
      # L'état résultant devrait être placé dans la clé `:machine_state_id`.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAzure
          b.use ReadState
        end
      end

      # Cette action est appelée en SSH dans la machine.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHRun
          end
        end
      end

      def self.action_prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncedFolders
        end
      end

      # Cette action est appelée à faire remonter la boîte à partir de rien.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use BoxCheckOutdated
          b.use ConnectAzure
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_prepare_boot
                  b2.use StartInstance # restart this instance
                else
                  b2.use MessageAlreadyCreated
                end
              end
            else
              b1.use action_prepare_boot
              b1.use RunInstance # launch a new instance
            end
          end
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAzure
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use action_halt
            b2.use Call, WaitForState, :stopped, 120 do |env2, b3|
              if env2[:result]
                b3.use action_up
              else
                # ??? it didn't stop
              end
            end
          end
        end
      end

      # La ferme de chargement automatique
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectAzure, action_root.join('connect_azure')
      autoload :IsCreated, action_root.join('is_created')
      autoload :IsStopped, action_root.join('is_stopped')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')
      autoload :MessageNotCreated, action_root.join('message_not_created')
      autoload :MessageWillNotDestroy, action_root.join('message_will_not_destroy')
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
      autoload :ReadWinrmInfo, action_root.join('read_winrm_info')
      autoload :ReadState, action_root.join('read_state')
      autoload :RestartVM, action_root.join('restart_vm')
      autoload :RunInstance, action_root.join('run_instance')
      autoload :StartInstance, action_root.join('start_instance')
      autoload :StopInstance, action_root.join('stop_instance')
      autoload :TerminateInstance, action_root.join('terminate_instance')
      autoload :TimedProvision, action_root.join('timed_provision')
      autoload :WaitForState, action_root.join('wait_for_state')
    end
  end
end
