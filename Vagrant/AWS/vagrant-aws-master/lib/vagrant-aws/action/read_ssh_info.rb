require "log4r"

module VagrantPlugins
  module AWS
    module Action
      # Cette action lit les informations SSH de la machine et les place la clé
      # `:machine_ssh_info` de l'environnement.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:aws_compute], env[:machine])

          @app.call(env)
        end

        def read_ssh_info(aws, machine)
          return nil if machine.id.nil?

          # Trouver l'appareil
          server = aws.servers.get(machine.id)
          if server.nil?
            # La machine est introuvable
            @logger.info("Machine couldn't be found, assuming it got destroyed.")
            machine.id = nil
            return nil
          end

          # remplacement d'attribut de lecture
          ssh_host_attribute = machine.provider_config.
              get_region_config(machine.provider_config.region).ssh_host_attribute
          # attributs d'hôte par défaut à essayer. REMARQUE : la commande est importante !
          ssh_attrs = [:dns_name, :public_ip_address, :private_ip_address]
          ssh_attrs = (Array(ssh_host_attribute) + ssh_attrs).uniq if ssh_host_attribute
          # essayez chaque attribut, sortez sur la première valeur
          host_value = nil
          while !host_value and attr_name = ssh_attrs.shift
            begin
              host_value = server.send(attr_name)
            rescue NoMethodError
              @logger.info("SSH host attribute not found #{attr_name}")
            end
          end

          return { :host => host_value, :port => 22 }
        end
      end
    end
  end
end
