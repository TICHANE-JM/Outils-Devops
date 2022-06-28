require "vagrant-aws/util/timer"

module VagrantPlugins
  module AWS
    module Action
      # C'est la même chose que la disposition intégrée, sauf qu'elle chronomètre
      # l'exécution de l'approvisionneur.
      class TimedProvision < Vagrant::Action::Builtin::Provision
        def run_provisioner(env, name, p)
          timer = Util::Timer.time do
            super
          end

          env[:metrics] ||= {}
          env[:metrics]["provisioner_times"] ||= []
          env[:metrics]["provisioner_times"] << [name, timer]
        end
      end
    end
  end
end
