require "log4r"
require "vagrant"

module VagrantPlugins
  module AWS
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        # Essayez d'obtenir la méthode d'action de la classe Action si elle existe,
        # sinon retournez nil pour montrer que nous ne supportons
        # pas l'action donnée.
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        # Exécutez une action personnalisée appelée "read_ssh_info" qui fait 
        # ce qu'elle dit et place les informations SSH résultantes
        # dans la clé `:machine_ssh_info` de l'environnement.
        env = @machine.action("read_ssh_info", lock: false)
        env[:machine_ssh_info]
      end

      def state
        # Exécutez une action personnalisée que nous définissons appelée
        # "read_state" qui fait ce qu'elle dit. Il place l'état dans la clé  
        # `:machine_state_id` dans l'environnement.
        env = @machine.action("read_state", lock: false)

        state_id = env[:machine_state_id]

        # Obtenez la description courte et longue
        short = I18n.t("vagrant_aws.states.short_#{state_id}")
        long  = I18n.t("vagrant_aws.states.long_#{state_id}")

        # Renvoyer l'objet MachineState
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? "new" : @machine.id
        "AWS (#{id})"
      end
    end
  end
end
