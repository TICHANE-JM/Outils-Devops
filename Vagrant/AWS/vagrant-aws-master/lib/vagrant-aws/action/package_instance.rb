require "log4r"
require 'vagrant/util/template_renderer'
require 'vagrant-aws/util/timer'
require 'vagrant/action/general/package'

module VagrantPlugins
  module AWS
    module Action
      # Cette action regroupe un serveur basé sur aws en cours d'exécution dans une boîte vagrant basée sur aws. Pour ce faire, il grave
      # l'instance de serveur vagrant-aws associée dans une AMI via fog. Une fois la gravure AMI réussie, l'action 
      # créera une archive tar .box en écrivant un fichier Vagrant avec le nouvel identifiant AMI.

      # Vagrant lui-même est livré avec une action de package générale, 
      # que cette action de plugin appelle. L'action générale fournit 
      # l'empaquetage réel ainsi que d'autres options telles que 
      # --include pour inclure des fichiers supplémentaires et 
      # --vagrantfile qui n'est pratiquement pas utile ici de toute façon.

      # L'action du plug-in du package virtualbox a été vaguement utilisée comme modèle pour cette classe.

      class PackageInstance < Vagrant::Action::General::Package
        include Vagrant::Util::Retryable

        def initialize(app, env)
          super
          @logger = Log4r::Logger.new("vagrant_aws::action::package_instance")
          env["package.include"] ||= []
        end

        alias_method :general_call, :call
        def call(env)
          # Initialiser les métriques si elles n'ont pas été
          env[:metrics] ||= {}

          # Ce bloc tente de graver l'instance de serveur dans une AMI
          begin
            # Obtenir l'objet serveur Fog pour une machine donnée
            server = env[:aws_compute].servers.get(env[:machine].id)

            env[:ui].info(I18n.t("vagrant_aws.packaging_instance", :instance_id => server.id))
            
            # Faire la demande à AWS pour créer une AMI à partir de l'instance de la machine
            ami_response = server.service.create_image server.id, "#{server.tags["Name"]} Package - #{Time.now.strftime("%Y%m%d-%H%M%S")}", ""

            # Trouver un identifiant ami
            @ami_id = ami_response.data[:body]["imageId"]

            # Tenter de graver l'instance aws dans une AMI dans le délai imparti
            env[:metrics]["instance_ready_time"] = Util::Timer.time do
              
              # Obtenez la configuration, pour définir le délai d'expiration ami burn
              region = env[:machine].provider_config.region
              region_config = env[:machine].provider_config.get_region_config(region)
              tries = region_config.instance_package_timeout / 2

              env[:ui].info(I18n.t("vagrant_aws.burning_ami", :ami_id => @ami_id))
              if !region_config.package_tags.empty?
                server.service.create_tags(@ami_id, region_config.package_tags)
              end

              # Vérifiez l'état de l'AMI toutes les 2 secondes jusqu'à ce que le délai d'attente de gravure de l'ami soit atteint
              begin
                retryable(:on => Fog::Errors::TimeoutError, :tries => tries) do
                  # Si nous sommes interrompus, ne vous inquiétez pas d'attendre
                  next if env[:interrupted]

                  # Besoin de mettre à jour l'ami_obj à chaque cycle
                  ami_obj = server.service.images.get(@ami_id)

                  # Attendez que le serveur soit prêt, déclenchez une erreur si le délai d'attente est atteint 
                  server.wait_for(2) {
                    if ami_obj.state == "failed"
                      raise Errors::InstancePackageError, 
                        ami_id: ami_obj.id,
                        err: ami_obj.state
                    end

                    ami_obj.ready?
                  }
                end
              rescue Fog::Errors::TimeoutError
                # Notify the user upon timeout
                raise Errors::InstancePackageTimeout,
                  timeout: region_config.instance_package_timeout
              end
            end
            env[:ui].info(I18n.t("vagrant_aws.packaging_instance_complete", :time_seconds => env[:metrics]["instance_ready_time"].to_i))
          rescue Fog::Compute::AWS::Error => e
            raise Errors::FogError, :message => e.message
          end

          # Gère les inclusions des options --include et --vagrantfile
          setup_package_files(env)

          # Configurez le répertoire temporaire pour les fichiers tarball
          @temp_dir = env[:tmp_path].join(Time.now.to_i.to_s)
          env["export.temp_dir"] = @temp_dir
          FileUtils.mkpath(env["export.temp_dir"])

          # Créez les fichiers Vagrantfile et metadata.json à partir de modèles à mettre dans la boîte
          create_vagrantfile(env)
          create_metadata_file(env)

          # Associez simplement quelques variables environnementales pour que
          # la superclasse fasse ce qu'il faut. Ensuite, appelez la
          # superclasse pour créer réellement l'archive tar (fichier .box)
          env["package.directory"] = env["export.temp_dir"]
          general_call(env)
          
          # Appelez toujours recovery pour nettoyer le répertoire temporaire
          clean_temp_dir
        end

        protected

        # Nettoyer le répertoire et les fichiers temporaires
        def clean_temp_dir
          if @temp_dir && File.exist?(@temp_dir)
            FileUtils.rm_rf(@temp_dir)
          end
        end

        # Cette méthode génère le Vagrantfile à la racine de la boîte. Pris à partir de 
        # VagrantPlugins::ProviderVirtualBox::Action::PackageVagrantfile
        def create_vagrantfile env
          File.open(File.join(env["export.temp_dir"], "Vagrantfile"), "w") do |f|
            f.write(TemplateRenderer.render("vagrant-aws_package_Vagrantfile", {
              region: env[:machine].provider_config.region,
              ami: @ami_id,
              template_root: template_root
            }))
          end
        end

        # Cette méthode génère le fichier metadata.json à la racine de la box.
        def create_metadata_file env
          File.open(File.join(env["export.temp_dir"], "metadata.json"), "w") do |f|
            f.write(TemplateRenderer.render("metadata.json", {
              template_root: template_root
            }))
          end
        end

        # Configure les fichiers --include et --vagrantfile qui peuvent être ajoutés en paramètre optionnel
        # Pris à partir de VagrantPlugins::ProviderVirtualBox::Action::SetupPackageFiles
        def setup_package_files(env)
          files = {}
          env["package.include"].each do |file|
            source = Pathname.new(file)
            dest   = nil

            # Si la source est relative, nous ajoutons le fichier tel quel au répertoire d'inclusion. 
            # Sinon, nous copions uniquement le fichier à la racine du répertoire d'inclusion.
            # Un peu étrange, mais semble correspondre à ce que les
            # gens attendent en fonction de l'histoire.
            if source.relative?
              dest = source
            else
              dest = source.basename
            end

            # Attribuer le mappage
            files[file] = dest
          end

          if env["package.vagrantfile"]
            # Les fichiers vagabonds sont traités de manière spéciale et mappés à un fichier spécifique
            files[env["package.vagrantfile"]] = "_Vagrantfile"
          end

          # Vérifier le mappage
          files.each do |from, _|
            raise Vagrant::Errors::PackageIncludeMissing,
              file: from if !File.exist?(from)
          end

          # Enregistrer le mappage
          env["package.files"] = files
        end

        # Utilisé pour trouver l'emplacement de base des modèles aws-vagrant
        def template_root
          AWS.source_root.join("templates")
        end

      end
    end
  end
end
