module VagrantPlugins
  module AWS
    module Action
      # Cela peut être utilisé avec "Call" intégré pour vérifier si la machine
      # est créée et branche dans le middleware.
      class IsCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].state.id != :not_created
          @app.call(env)
        end
      end
    end
  end
end
