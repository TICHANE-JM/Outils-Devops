# encodage : utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
module VagrantPlugins
  module Azure
    module Action
      class MessageNotCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_azure.not_created'))
          @app.call(env)
        end
      end
    end
  end
end
