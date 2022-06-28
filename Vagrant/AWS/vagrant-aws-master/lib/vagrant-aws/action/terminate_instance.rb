require "log4r"
require "json"

module VagrantPlugins
  module AWS
    module Action
      # Cela met fin à l'instance en cours d'exécution.
      class TerminateInstance
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws::action::terminate_instance")
        end

        def call(env)
          server         = env[:aws_compute].servers.get(env[:machine].id)
          region         = env[:machine].provider_config.region
          region_config  = env[:machine].provider_config.get_region_config(region)

          elastic_ip     = region_config.elastic_ip

          # Libère l'IP élastique
          ip_file = env[:machine].data_dir.join('elastic_ip')
          if ip_file.file?
            release_address(env,ip_file.read)
            ip_file.delete
          end

          # Détruisez le serveur et supprimez l'ID de suivi
          env[:ui].info(I18n.t("vagrant_aws.terminating"))
          server.destroy
          env[:machine].id = nil

          @app.call(env)
        end

        # Libérer une adresse IP élastique
        def release_address(env,eip)
          h = JSON.parse(eip)
          # Utilisez association_id et allocation_id pour VPC, utilisez une adresse IP publique pour EC2
          if h['association_id']
            env[:aws_compute].disassociate_address(nil,h['association_id'])
            env[:aws_compute].release_address(h['allocation_id'])
          else
            env[:aws_compute].disassociate_address(h['public_ip'])
            env[:aws_compute].release_address(h['public_ip'])
          end
        end
      end
    end
  end
end
