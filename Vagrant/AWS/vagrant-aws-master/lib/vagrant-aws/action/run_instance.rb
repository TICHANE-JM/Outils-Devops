require "log4r"
require 'json'

require 'vagrant/util/retryable'

require 'vagrant-aws/util/timer'

module VagrantPlugins
  module AWS
    module Action
      # Cela exécute l'instance configurée.
      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws::action::run_instance")
        end

        def call(env)
          # Initialiser les métriques si elles n'ont pas été
          env[:metrics] ||= {}

          # Obtenez la région dans laquelle nous allons démarrer
          region = env[:machine].provider_config.region

          # Obtenir les configurations
          region_config         = env[:machine].provider_config.get_region_config(region)
          ami                   = region_config.ami
          availability_zone     = region_config.availability_zone
          placement_group       = region_config.placement_group
          instance_type         = region_config.instance_type
          keypair               = region_config.keypair_name
          private_ip_address    = region_config.private_ip_address
          security_groups       = region_config.security_groups
          subnet_id             = region_config.subnet_id
          tags                  = region_config.tags
          user_data             = region_config.user_data
          block_device_mapping  = region_config.block_device_mapping
          elastic_ip            = region_config.elastic_ip
          terminate_on_shutdown = region_config.terminate_on_shutdown
          iam_instance_profile_arn  = region_config.iam_instance_profile_arn
          iam_instance_profile_name = region_config.iam_instance_profile_name
          monitoring            = region_config.monitoring
          ebs_optimized         = region_config.ebs_optimized
          source_dest_check     = region_config.source_dest_check
          associate_public_ip   = region_config.associate_public_ip
          kernel_id             = region_config.kernel_id
          tenancy               = region_config.tenancy

          # S'il n'y a pas de paire de clés, avertissez l'utilisateur
          if !keypair
            env[:ui].warn(I18n.t("vagrant_aws.launch_no_keypair"))
          end

          # S'il existe un ID de sous-réseau, avertissez l'utilisateur
          if subnet_id && !elastic_ip
            env[:ui].warn(I18n.t("vagrant_aws.launch_vpc_warning"))
          end

          # Lancement!
          env[:ui].info(I18n.t("vagrant_aws.launching_instance"))
          env[:ui].info(" -- Type: #{instance_type}")
          env[:ui].info(" -- AMI: #{ami}")
          env[:ui].info(" -- Region: #{region}")
          env[:ui].info(" -- Availability Zone: #{availability_zone}") if availability_zone
          env[:ui].info(" -- Placement Group: #{placement_group}") if placement_group
          env[:ui].info(" -- Keypair: #{keypair}") if keypair
          env[:ui].info(" -- Subnet ID: #{subnet_id}") if subnet_id
          env[:ui].info(" -- IAM Instance Profile ARN: #{iam_instance_profile_arn}") if iam_instance_profile_arn
          env[:ui].info(" -- IAM Instance Profile Name: #{iam_instance_profile_name}") if iam_instance_profile_name
          env[:ui].info(" -- Private IP: #{private_ip_address}") if private_ip_address
          env[:ui].info(" -- Elastic IP: #{elastic_ip}") if elastic_ip
          env[:ui].info(" -- User Data: yes") if user_data
          env[:ui].info(" -- Security Groups: #{security_groups.inspect}") if !security_groups.empty?
          env[:ui].info(" -- User Data: #{user_data}") if user_data
          env[:ui].info(" -- Block Device Mapping: #{block_device_mapping}") if block_device_mapping
          env[:ui].info(" -- Terminate On Shutdown: #{terminate_on_shutdown}")
          env[:ui].info(" -- Monitoring: #{monitoring}")
          env[:ui].info(" -- EBS optimized: #{ebs_optimized}")
          env[:ui].info(" -- Source Destination check: #{source_dest_check}")
          env[:ui].info(" -- Assigning a public IP address in a VPC: #{associate_public_ip}")
          env[:ui].info(" -- VPC tenancy specification: #{tenancy}")

          options = {
            :availability_zone         => availability_zone,
            :placement_group           => placement_group,
            :flavor_id                 => instance_type,
            :image_id                  => ami,
            :key_name                  => keypair,
            :private_ip_address        => private_ip_address,
            :subnet_id                 => subnet_id,
            :iam_instance_profile_arn  => iam_instance_profile_arn,
            :iam_instance_profile_name => iam_instance_profile_name,
            :tags                      => tags,
            :user_data                 => user_data,
            :block_device_mapping      => block_device_mapping,
            :instance_initiated_shutdown_behavior => terminate_on_shutdown == true ? "terminate" : nil,
            :monitoring                => monitoring,
            :ebs_optimized             => ebs_optimized,
            :associate_public_ip       => associate_public_ip,
            :kernel_id                 => kernel_id,
            :tenancy                   => tenancy
          }

          if !security_groups.empty?
            security_group_key = options[:subnet_id].nil? ? :groups : :security_group_ids
            options[security_group_key] = security_groups
            env[:ui].warn(I18n.t("vagrant_aws.warn_ssh_access")) unless allows_ssh_port?(env, security_groups, subnet_id)
          end

          begin
            server = env[:aws_compute].servers.create(options)
          rescue Fog::Compute::AWS::NotFound => e
            # Le sous-réseau non valide n'a pas sa propre erreur, nous attrapons et
            # vérifions le message d'erreur ici.
            if e.message =~ /subnet ID/
              raise Errors::FogError,
                :message => "Subnet ID not found: #{subnet_id}"
            end

            raise
          rescue Fog::Compute::AWS::Error => e
            raise Errors::FogError, :message => e.message
          rescue Excon::Errors::HTTPStatusError => e
            raise Errors::InternalFogError,
              :error => e.message,
              :response => e.response.body
          end

          # Enregistrez immédiatement l'ID puisqu'il est créé à ce stade.
          env[:machine].id = server.id

          # Attendez d'abord que l'instance soit prête
          env[:metrics]["instance_ready_time"] = Util::Timer.time do
            tries = region_config.instance_ready_timeout / 2

            env[:ui].info(I18n.t("vagrant_aws.waiting_for_ready"))
            begin
              retryable(:on => Fog::Errors::TimeoutError, :tries => tries) do
                # Si nous sommes interrompus, ne vous inquiétez pas d'attendre
                next if env[:interrupted]

                # Attendez que le serveur soit prêt
                server.wait_for(2, region_config.instance_check_interval) { ready? }
              end
            rescue Fog::Errors::TimeoutError
              # Supprimer l'instance
              terminate(env)

              # Avertir l'utilisateur
              raise Errors::InstanceReadyTimeout,
                timeout: region_config.instance_ready_timeout
            end
          end

          @logger.info("Time to instance ready: #{env[:metrics]["instance_ready_time"]}")

          # Allouer et associer une IP élastique si demandé
          if elastic_ip
            domain = subnet_id ? 'vpc' : 'standard'
            do_elastic_ip(env, domain, server, elastic_ip)
          end

          # Définir les contrôles de destination source
          if !source_dest_check.nil?
            if server.vpc_id.nil?
                env[:ui].warn(I18n.t("vagrant_aws.source_dest_checks_no_vpc"))
            else
                begin
                    attrs = {
                        "SourceDestCheck.Value" => source_dest_check
                    }
                    env[:aws_compute].modify_instance_attribute(server.id, attrs)
                rescue Fog::Compute::AWS::Error => e
                    raise Errors::FogError, :message => e.message
                end
            end
        end

          if !env[:interrupted]
            env[:metrics]["instance_ssh_time"] = Util::Timer.time do
              # Attendez que SSH soit prêt.
              env[:ui].info(I18n.t("vagrant_aws.waiting_for_ssh"))
              network_ready_retries = 0
              network_ready_retries_max = 10
              while true
                # Si nous sommes interrompus, revenez en arrière
                break if env[:interrupted]
                # Lorsqu'une instance ec2 apparaît, sa mise en réseau peut ne pas être prête au
                # moment où nous nous connectons.
                begin
                  break if env[:machine].communicate.ready?
                rescue Exception => e
                  if network_ready_retries < network_ready_retries_max then
                    network_ready_retries += 1
                    @logger.warn(I18n.t("vagrant_aws.waiting_for_ssh, retrying"))
                  else
                    raise e
                  end
                end
                sleep 2
              end
            end

            @logger.info("Time for SSH ready: #{env[:metrics]["instance_ssh_time"]}")

            # Prêt et démarré !
            env[:ui].info(I18n.t("vagrant_aws.ready"))
          end

          # Terminer l'instance si nous avons été interrompus
          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if env[:machine].provider.state.id != :not_created
            # Annuler l'importation
            terminate(env)
          end
        end

        def allows_ssh_port?(env, test_sec_groups, is_vpc)
          port = 22 # TODO get ssh_info port
          test_sec_groups = [ "default" ] if test_sec_groups.empty? # AWS default security group
          # filtrer les groupes par nom ou group_id (vpc)
          groups = test_sec_groups.map do |tsg|
            env[:aws_compute].security_groups.all.select { |sg| tsg == (is_vpc ? sg.group_id : sg.name) }
          end.flatten
          # filtrer les règles TCP
          rules = groups.map { |sg| sg.ip_permissions.select { |r| r["ipProtocol"] == "tcp" } }.flatten
          # teste si une plage inclut le port
          !rules.select { |r| (r["fromPort"]..r["toPort"]).include?(port) }.empty?
        end

        def do_elastic_ip(env, domain, server, elastic_ip)
          if elastic_ip =~ /\d+\.\d+\.\d+\.\d+/
            begin
              address = env[:aws_compute].addresses.get(elastic_ip)
            rescue
              handle_elastic_ip_error(env, "Could not retrieve Elastic IP: #{elastic_ip}")
            end
            if address.nil?
              handle_elastic_ip_error(env, "Elastic IP not available: #{elastic_ip}")
            end
            @logger.debug("Public IP #{address.public_ip}")
          else
            begin
              allocation = env[:aws_compute].allocate_address(domain)
            rescue
              handle_elastic_ip_error(env, "Could not allocate Elastic IP.")
            end
            @logger.debug("Public IP #{allocation.body['publicIp']}")
          end

          # Associez l'adresse et enregistrez les métadonnées dans un hachage
          h = nil
          if domain == 'vpc'
            # Le VPC nécessite un ID d'allocation pour attribuer une adresse IP
            if address
              association = env[:aws_compute].associate_address(server.id, nil, nil, address.allocation_id)
            else
              association = env[:aws_compute].associate_address(server.id, nil, nil, allocation.body['allocationId'])
              # Stocker uniquement les données de version pour une adresse attribuée
              h = { :allocation_id => allocation.body['allocationId'], :association_id => association.body['associationId'], :public_ip => allocation.body['publicIp'] }
            end
          else
            # Les instances EC2 standard n'ont besoin que de l'adresse IP allouée
            if address
              association = env[:aws_compute].associate_address(server.id, address.public_ip)
            else
              association = env[:aws_compute].associate_address(server.id, allocation.body['publicIp'])
              h = { :public_ip => allocation.body['publicIp'] }
            end
          end

          unless association.body['return']
            @logger.debug("Could not associate Elastic IP.")
            terminate(env)
            raise Errors::FogError,
                            :message => "Could not allocate Elastic IP."
          end

          # Enregistrez cette adresse IP dans le répertoire de données afin qu'elle puisse être libérée lorsque l'instance est détruite
          if h
            ip_file = env[:machine].data_dir.join('elastic_ip')
            ip_file.open('w+') do |f|
              f.write(h.to_json)
            end
          end
        end

        def handle_elastic_ip_error(env, message)
          @logger.debug(message)
          terminate(env)
          raise Errors::FogError,
                          :message => message
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end
      end
    end
  end
end
