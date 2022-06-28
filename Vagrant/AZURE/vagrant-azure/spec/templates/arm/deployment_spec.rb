# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.

require "spec_helper"
require "vagrant-azure/util/template_renderer"

module VagrantPlugins
  module Azure
    describe "modèle de déploiement" do

      let(:options) {
        {
            operating_system: "linux",
            location: "location",
            endpoints: [22],
            data_disks: []
        }
      }

      describe "Les bases" do
        let(:subject) {
          render(options)
        }

        it "doit spécifier le schéma" do
          expect(subject["$schema"]).to eq("http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json")
        end

        it "doit spécifier la version du contenu" do
          expect(subject["contentVersion"]).to eq("1.0.0.0")
        end

        it "devrait avoir 10 paramètres" do
          expect(subject["parameters"].count).to eq(10)
        end

        it "devrait avoir 14 variables" do
          expect(subject["variables"].count).to eq(14)
        end

        it "devrait avoir 5 ressources" do
          expect(subject["resources"].count).to eq(5)
        end
      end

      describe "Ressources" do
        describe "machine virtuelle" do
          let(:subject) {
            render(options)["resources"].detect {|vm| vm["type"] == "Microsoft.Compute/virtualMachines"}
          }

          it "devrait dépendre de 1 ressources sans AV Set" do
            expect(subject["dependsOn"].count).to eq(1)
          end

          describe "avec ensemble AV" do
            let(:subject) {
              template = render(options.merge(availability_set_name: "avSet"))
              template["resources"].detect {|vm| vm["type"] == "Microsoft.Compute/virtualMachines"}
            }

            it "devrait dépendre de 2 ressources avec un AV Set" do
              expect(subject["dependsOn"].count).to eq(2)
            end
          end

          describe "avec référence de disque géré" do
            let(:subject) {
              template = render(options.merge(vm_managed_image_id: "image_id"))
              template["resources"].detect {|vm| vm["type"] == "Microsoft.Compute/virtualMachines"}
            }

            it "doit avoir un identifiant de référence d'image défini sur image_id" do
              expect(subject["properties"]["storageProfile"]["imageReference"]["id"]).to eq("image_id")
            end
          end
        end

        describe "image gérée" do
          let(:subject) {
            render(options)["resources"].detect {|vm| vm["type"] == "Microsoft.Compute/images"}
          }
          describe "avec vhd personnalisé" do
            let(:vhd_uri_options) {
              options.merge(
                  vhd_uri: "https://my_image.vhd",
                  operating_system: "Foo"
              )
            }
            let(:subject) {
              render(vhd_uri_options)["resources"].detect {|vm| vm["type"] == "Microsoft.Compute/images"}
            }

            it "devrait exister" do
              expect(subject).not_to be_nil
            end

            it "devrait définir le blob_uri" do
              expect(subject["properties"]["storageProfile"]["osDisk"]["blobUri"]).to eq(vhd_uri_options[:vhd_uri])
            end

            it "devrait définir le osType" do
              expect(subject["properties"]["storageProfile"]["osDisk"]["osType"]).to eq(vhd_uri_options[:operating_system])
            end
          end

          it "ne devrait pas exister" do
            expect(subject).to be_nil
          end
        end
      end

      describe "paramètres" do
        let(:base_keys) {
          %w( storageAccountType adminUserName dnsLabelPrefix nsgLabelPrefix vmSize vmName subnetName virtualNetworkName
              winRmPort )
        }

        let(:nix_keys) {
          base_keys + ["sshKeyData"]
        }

        let(:subject) {
          render(options)["parameters"]
        }

        it "doit inclure toutes les clés de paramètre *nix" do
          expect(subject.keys).to contain_exactly(*nix_keys)
        end

        describe "avec Windows" do
          let(:subject) {
            render(options.merge(operating_system: "Windows"))["parameters"]
          }

          let(:win_keys) {
            base_keys + ["adminPassword"]
          }

          it "doit inclure toutes les clés de paramètre Windows" do
            expect(subject.keys).to contain_exactly(*win_keys)
          end
        end
      end

      describe "variables" do
        let(:keys) {
          %w(location addressPrefix subnetPrefix nicName publicIPAddressName publicIPAddressType
              networkSecurityGroupName sshKeyPath vnetID subnetRef apiVersion
              singleQuote doubleQuote managedImageName)
        }

        let(:subject) {
          render(options)["variables"]
        }

        it "doit inclure toutes les clés de paramètre Windows" do
          expect(subject.keys).to contain_exactly(*keys)
        end
      end


      def render(options)
        JSON.parse(VagrantPlugins::Azure::Util::TemplateRenderer.render("arm/deployment.json", options))
      end
    end
  end
end
