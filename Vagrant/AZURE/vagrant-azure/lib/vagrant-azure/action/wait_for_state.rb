# encodage : utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
require 'log4r'
require 'timeout'

module VagrantPlugins
  module Azure
    module Action
      class WaitForState
        # env[:result] sera faux en cas de timeout.
        # @param [Symbol] état État de la machine cible.
        # @param [Number] timeout Timeout en secondes.
        # @param [Object] env environnement vagrant
        def initialize(app, env, state, timeout)
          @app     = app
          @logger  = Log4r::Logger.new('vagrant_azure::action::wait_for_state')
          @state   = state
          @timeout = timeout
          @env     = env
        end

        def call(env)
          env[:result] = true
          if env[:machine].state.id == @state
            @logger.info(I18n.t('vagrant_azure.already_status', :status => @state))
          else
            @logger.info("Waiting for machine to reach state #{@state}")
            begin
              Timeout.timeout(@timeout) do
                until env[:machine].state.id == @state
                  sleep 2
                end
              end
            rescue Timeout::Error
              env[:result] = false # couldn't reach state in time
            end
          end
          @app.call(env)
        end
      end
    end
  end
end
