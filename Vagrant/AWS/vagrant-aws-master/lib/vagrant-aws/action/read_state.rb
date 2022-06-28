require "log4r"

module VagrantPlugins
  module AWS
    module Action
      # Cette action lit l'état de la machine et le place dans la clé
      # `:machine_state_id` de l'environnement.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:aws_compute], env[:machine])

          @app.call(env)
        end

        def read_state(aws, machine)
          return :not_created if machine.id.nil?

          # Trouver l'appareil
          server = aws.servers.get(machine.id)
          if server.nil? || [:"shutting-down", :terminated].include?(server.state.to_sym)
            # La machine est introuvable
            @logger.info("Machine not found or terminated, assuming it got destroyed.")
            machine.id = nil
            return :not_created
          end

          # Renvoie l'état
          return server.state.to_sym
        end
      end
    end
  end
end
