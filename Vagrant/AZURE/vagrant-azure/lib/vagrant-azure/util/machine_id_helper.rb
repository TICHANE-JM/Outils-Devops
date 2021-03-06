# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.

module VagrantPlugins
  module Azure
    module Util
      module MachineIdHelper
        def parse_machine_id(id)
          parts = id.split(':')
          {
              group: parts[0],
              name: parts[1],
              location: parts[2]
          }
        end

        def serialize_machine_id(resource_group, vm_name, location)
          [resource_group, vm_name, location].join(':')
        end
      end
    end
  end
end
