# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.

require "erb"

module VagrantPlugins
  module Azure
    module Util
      class TemplateRenderer
        class << self
          # Rendre un modèle donné et renvoyer le résultat. Cette méthode prend éventuellement un bloc qui sera
          # transmis au moteur de rendu avant le rendu, ce qui permet à l'appelant de définir toutes
          # les variables de vue dans le moteur de rendu lui-même.
          #
          # @return [String] Rendered template
          def render(*args)
            render_with(:render, *args)
          end

          # Méthode utilisée en interne pour assécher les autres moteurs de rendu. Cette méthode crée
          # et configure le moteur de rendu avant d'appeler une méthode spécifiée sur celui-ci.
          def render_with(method, template, data = {})
            renderer = new(template, data)
            yield renderer if block_given?
            renderer.send(method.to_sym)
          end
        end

        def initialize(template, data = {})
          @data = data
          @template = template
        end

        def render
          str = File.read(full_template_path)
          ERB.new(str).result(OpenStruct.new(@data).instance_eval { binding })
        end

        # Renvoie le chemin d'accès complet au modèle, en tenant compte du
        # répertoire gem et en ajoutant l'extension `.erb` à la fin.
        #
        # @return [String]
        def full_template_path
          template_root.join("#{@template}.erb").to_s.squeeze("/")
        end

        def template_root
          Azure.source_root.join("templates")
        end
      end
    end
  end
end
