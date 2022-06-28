# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
module VagrantPlugins
  module Azure
    module Action
      class IsStopped
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].state.id == :stopped
          @app.call(env)
        end
      end
    end
  end
end
