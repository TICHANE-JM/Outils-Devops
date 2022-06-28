require 'vagrant-aws/util/elb'

module VagrantPlugins
  module AWS
    module Action
      # Cela enregistre l'instance dans ELB
      class ElbRegisterInstance
        include ElasticLoadBalancer

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws::action::elb_register_instance")
        end

        def call(env)
          @app.call(env)
          if elb_name = env[:machine].provider_config.elb
            register_instance env, elb_name, env[:machine].id
          end
        end
      end
    end
  end
end
