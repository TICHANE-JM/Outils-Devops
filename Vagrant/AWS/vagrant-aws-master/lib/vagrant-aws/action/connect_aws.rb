require "fog"
require "log4r"

module VagrantPlugins
  module AWS
    module Action
      # Cette action se connecte à AWS, vérifie le travail des informations d'identification
      # et place l'objet de connexion AWS dans la clé 
      # `:aws_compute` de l'environnement.
      class ConnectAWS
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws::action::connect_aws")
        end

        def call(env)
          # Obtenez la région dans laquelle nous allons démarrer
          region = env[:machine].provider_config.region

          # Obtenir les configurations
          region_config = env[:machine].provider_config.get_region_config(region)

          # Construire la configuration du fog
          fog_config = {
            :provider => :aws,
            :region   => region
          }
          if region_config.use_iam_profile
            fog_config[:use_iam_profile] = true
          else
            fog_config[:aws_access_key_id] = region_config.access_key_id
            fog_config[:aws_secret_access_key] = region_config.secret_access_key
            fog_config[:aws_session_token] = region_config.session_token
          end

          fog_config[:endpoint] = region_config.endpoint if region_config.endpoint
          fog_config[:version]  = region_config.version if region_config.version

          @logger.info("Connecting to AWS...")
          env[:aws_compute] = Fog::Compute.new(fog_config)
          env[:aws_elb]     = Fog::AWS::ELB.new(fog_config.except(:provider, :endpoint))

          @app.call(env)
        end
      end
    end
  end
end
