require "log4r"
require "timeout"

module VagrantPlugins
  module AWS
    module Action
      # Cette action attendra qu'une machine atteigne un état spécifique ou quitte par timeout
      class WaitForState
        # env[:result] sera faux en cas de timeout.
        # @param [Symbole] state État de la machine cible.
        # @param [Number] timeout Délai d'attente en secondes.
        def initialize(app, env, state, timeout)
          @app     = app
          @logger  = Log4r::Logger.new("vagrant_aws::action::wait_for_state")
          @state   = state
          @timeout = timeout
        end

        def call(env)
          env[:result] = true
          if env[:machine].state.id == @state
            @logger.info(I18n.t("vagrant_aws.already_status", :status => @state))
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
