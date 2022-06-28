# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
module VagrantPlugins
  module Azure
    module Util
      class Timer
        def self.time
          start_time = Time.now.to_f
          yield
          end_time = Time.now.to_f

          end_time - start_time
        end
      end
    end
  end
end
