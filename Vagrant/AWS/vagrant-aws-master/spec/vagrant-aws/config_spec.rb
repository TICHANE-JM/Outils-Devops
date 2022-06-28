require "vagrant-aws/config"
require 'rspec/its'

# supprimer les avertissements d'obsolescence
# (jusqu'à ce que quelqu'un décide de mettre à jour l'ensemble du fichier de spécifications vers rspec 3.4)
RSpec.configure do |config|
  # ...
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

describe VagrantPlugins::AWS::Config do
  let(:instance) { described_class.new }

  # Assurez-vous que les tests ne sont pas affectés par les variables d'environnement d'informations d'identification AWS
  before :each do
    ENV.stub(:[] => nil)
  end

  describe "defaults" do
    subject do
      instance.tap do |o|
        o.finalize!
      end
    end

    its("access_key_id")     { should be_nil }
    its("ami")               { should be_nil }
    its("availability_zone") { should be_nil }
    its("instance_ready_timeout") { should == 120 }
    its("instance_check_interval") { should == 2 }
    its("instance_package_timeout") { should == 600 }
    its("instance_type")     { should == "m3.medium" }
    its("keypair_name")      { should be_nil }
    its("private_ip_address") { should be_nil }
    its("region")            { should == "us-east-1" }
    its("secret_access_key") { should be_nil }
    its("session_token") { should be_nil }
    its("security_groups")   { should == [] }
    its("subnet_id")         { should be_nil }
    its("iam_instance_profile_arn") { should be_nil }
    its("iam_instance_profile_name") { should be_nil }
    its("tags")              { should == {} }
    its("package_tags")      { should == {} }
    its("user_data")         { should be_nil }
    its("use_iam_profile")   { should be false }
    its("block_device_mapping")  {should == [] }
    its("elastic_ip")        { should be_nil }
    its("terminate_on_shutdown") { should == false }
    its("ssh_host_attribute") { should be_nil }
    its("monitoring")        { should == false }
    its("ebs_optimized")     { should == false }
    its("source_dest_check")       { should be_nil }
    its("associate_public_ip")     { should == false }
    its("unregister_elb_from_az") { should == true }
    its("tenancy")     { should == "default" }
  end

  describe "overriding defaults" do
    # Je ne fais généralement pas de méta-programme dans les tests, mais
    # il s'agit d'un test passe-partout très simple, donc je coupe les coins ronds ici.
    # Il définit simplement chacun de ces attributs sur "foo"
    # de manière isolée, lit la valeur et affirme que le résultat approprié revient.
    [:access_key_id, :ami, :availability_zone, :instance_ready_timeout,
      :instance_package_timeout, :instance_type, :keypair_name, :ssh_host_attribute,
      :ebs_optimized, :region, :secret_access_key, :session_token, :monitoring,
      :associate_public_ip, :subnet_id, :tags, :package_tags, :elastic_ip,
      :terminate_on_shutdown, :iam_instance_profile_arn, :iam_instance_profile_name,
      :use_iam_profile, :user_data, :block_device_mapping,
      :source_dest_check].each do |attribute|

      it "ne doit pas utiliser par défaut #{attribute} s'il est remplacé" do
        # mais ceux-ci doivent toujours être réunis, vous devez donc les définir tous ou rien
        instance.send("access_key_id=".to_sym, "foo")
        instance.send("secret_access_key=".to_sym, "foo")
        instance.send("session_token=".to_sym, "foo")
        instance.send("#{attribute}=".to_sym, "foo")
        instance.finalize!
        instance.send(attribute).should == "foo"
      end
    end
    it "ne devrait pas définir par défaut security_groups s'il est remplacé" do
      instance.security_groups = "foo"
      instance.finalize!
      instance.security_groups.should == ["foo"]
    end
  end

  describe "obtenir des informations d'identification de l'environnement" do
    context "sans variables d'environnement d'informations d'identification EC2" do
      subject do
        instance.tap do |o|
          o.finalize!
        end
      end

      its("access_key_id")     { should be_nil }
      its("secret_access_key") { should be_nil }
      its("session_token")     { should be_nil }
    end

    context "avec des variables d'environnement d'informations d'identification EC2" do
      before :each do
        ENV.stub(:[]).with("AWS_ACCESS_KEY_ID").and_return("access_key")
        ENV.stub(:[]).with("AWS_SECRET_ACCESS_KEY").and_return("secret_key")
        ENV.stub(:[]).with("AWS_SESSION_TOKEN").and_return("session_token")
      end

      subject do
        instance.tap do |o|
          o.finalize!
        end
      end

      its("access_key_id")     { should == "access_key" }
      its("secret_access_key") { should == "secret_key" }
      its("session_token")     { should == "session_token" }
    end
  end


  describe "obtenir des informations d'identification lorsqu'il existe un profil AWS" do
    ## ENV a été nuké donc ENV['HOME'] sera une chaîne vide lorsque Credentials#get_aws_info sera appelé
    let(:filename_cfg)  { "/.aws/config" }
    let(:filename_keys) { "/.aws/credentials" }
    let(:data_cfg)      {
"[default]
region=eu-west-1
output=json

[profile user1]
region=us-east-1
output=text

[profile user2]
region=us-east-1
output=text

[profile user3]
region=us-west-2
output=text
" }
    let(:data_keys)     {
"[default]
aws_access_key_id=AKIdefault
aws_secret_access_key=PASSdefault

[user1]
aws_access_key_id=AKIuser1
aws_secret_access_key=PASSuser1

[user2]
aws_access_key_id=AKIuser2
aws_secret_access_key=PASSuser2
aws_session_token=TOKuser2

[user3]
aws_access_key_id=AKIuser3
aws_secret_access_key=PASSuser3
aws_session_token= TOKuser3
" }
    # noms de fichiers et données de fichiers lors de l'utilisation de AWS_SHARED_CREDENTIALS_FILE et AWS_CONFIG_FILE
    let(:sh_dir)           { "/aws_shared/" }
    let(:sh_filename_cfg)  { sh_dir + "config" }
    let(:sh_filename_keys) { sh_dir + "credentials" }
    let(:sh_data_cfg)      { "[default]\nregion=sh-region\noutput=text" }
    let(:sh_data_keys)     { "[default]\naws_access_key_id=AKI_set_shared\naws_secret_access_key=set_shared_foobar" }

    context "avec ensemble de variables d'environnement d'informations d'identification EC2" do
      subject do
        ENV.stub(:[]).with("AWS_ACCESS_KEY_ID").and_return("env_access_key")
        ENV.stub(:[]).with("AWS_SECRET_ACCESS_KEY").and_return("env_secret_key")
        ENV.stub(:[]).with("AWS_SESSION_TOKEN").and_return("env_session_token")
        ENV.stub(:[]).with("AWS_DEFAULT_REGION").and_return("env_region")
        allow(File).to receive(:read).with(filename_cfg).and_return(data_cfg)
        allow(File).to receive(:read).with(filename_keys).and_return(data_keys)
        instance.tap do |o|
          o.finalize!
        end
      end
      its("access_key_id")        { should == "env_access_key" }
      its("secret_access_key")    { should == "env_secret_key" }
      its("session_token")        { should == "env_session_token" }
      its("region")               { should == "env_region" }
    end

    context "sans variables d'environnement d'informations d'identification EC2 mais avec AWS_CONFIG_FILE et AWS_SHARED_CREDENTIALS_FILE définis" do
      subject do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(filename_cfg).and_return(data_cfg)
        allow(File).to receive(:read).with(filename_keys).and_return(data_keys)
        ENV.stub(:[]).with("AWS_CONFIG_FILE").and_return(sh_filename_cfg)
        ENV.stub(:[]).with("AWS_SHARED_CREDENTIALS_FILE").and_return(sh_filename_keys)
        allow(File).to receive(:read).with(sh_filename_cfg).and_return(sh_data_cfg)
        allow(File).to receive(:read).with(sh_filename_keys).and_return(sh_data_keys)
        instance.tap do |o|
          o.finalize!
        end
      end
      its("access_key_id")         { should == "AKI_set_shared" }
      its("secret_access_key")     { should == "set_shared_foobar" }
      its("session_token")         { should be_nil }
      its("region")                { should == "sh-region" }
    end

    context "sans variables d'environnement d'informations d'identification et retour au profil par défaut à l'emplacement par défaut" do
      subject do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(filename_cfg).and_return(data_cfg)
        allow(File).to receive(:read).with(filename_keys).and_return(data_keys)
        instance.tap do |o|
          o.finalize!
        end
      end
      its("access_key_id")         { should == "AKIdefault" }
      its("secret_access_key")     { should == "PASSdefault" }
      its("session_token")         { should be_nil }
    end

    context "sans aucune variable d'environnement d'identification et en choisissant un profil" do
      subject do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(filename_cfg).and_return(data_cfg)
        allow(File).to receive(:read).with(filename_keys).and_return(data_keys)
        instance.aws_profile = "user3"
        instance.tap do |o|
          o.finalize!
        end
      end
      its("access_key_id")         { should == "AKIuser3" }
      its("secret_access_key")     { should == "PASSuser3" }
      its("session_token")         { should == "TOKuser3" }
      its("region")                { should == "us-west-2" }
    end
  end



  describe "region config" do
    let(:config_access_key_id)     { "foo" }
    let(:config_ami)               { "foo" }
    let(:config_instance_type)     { "foo" }
    let(:config_keypair_name)      { "foo" }
    let(:config_region)            { "foo" }
    let(:config_secret_access_key) { "foo" }
    let(:config_session_token)     { "foo" }

    def set_test_values(instance)
      instance.access_key_id     = config_access_key_id
      instance.ami               = config_ami
      instance.instance_type     = config_instance_type
      instance.keypair_name      = config_keypair_name
      instance.region            = config_region
      instance.secret_access_key = config_secret_access_key
      instance.session_token     = config_session_token
    end

    it "devrait lever une exception s'il n'est pas finalisé" do
      expect { instance.get_region_config("us-east-1") }.
        to raise_error
    end

    context "sans jeu de configuration spécifique" do
      subject do
        # Définir les valeurs sur l'objet de niveau supérieur
        set_test_values(instance)

        # Finaliser afin que nous puissions obtenir la configuration de la région
        instance.finalize!

        # Obtenir une région de niveau inférieur
        instance.get_region_config("us-east-1")
      end

      its("access_key_id")     { should == config_access_key_id }
      its("ami")               { should == config_ami }
      its("instance_type")     { should == config_instance_type }
      its("keypair_name")      { should == config_keypair_name }
      its("region")            { should == config_region }
      its("secret_access_key") { should == config_secret_access_key }
      its("session_token")     { should == config_session_token }
    end

    context "avec un jeu de configuration spécifique" do
      let(:region_name) { "hashi-region" }

      subject do
        # Set the values on a specific region
        instance.region_config region_name do |config|
          set_test_values(config)
        end

        # Finalize so we can get the region config
        instance.finalize!

        # Get the region
        instance.get_region_config(region_name)
      end

      its("access_key_id")     { should == config_access_key_id }
      its("ami")               { should == config_ami }
      its("instance_type")     { should == config_instance_type }
      its("keypair_name")      { should == config_keypair_name }
      its("region")            { should == region_name }
      its("secret_access_key") { should == config_secret_access_key }
      its("session_token")     { should == config_session_token }
    end

    describe "héritage de la configuration parent" do
      let(:region_name) { "hashi-region" }

      subject do
        # Définir les valeurs sur une région spécifique
        instance.region_config region_name do |config|
          config.ami = "child"
        end

        # Définir des valeurs de niveau supérieur
        instance.access_key_id = "parent"
        instance.secret_access_key = "parent"
        instance.ami = "parent"

        # Finaliser et obtenir la région
        instance.finalize!
        instance.get_region_config(region_name)
      end

      its("access_key_id") { should == "parent" }
      its("secret_access_key") { should == "parent" }
      its("ami")           { should == "child" }
    end

    describe "configuration des raccourcis" do
      subject do
        # Utilisez la configuration du raccourci pour définir certaines valeurs
        instance.region_config "us-east-1", :ami => "child"
        instance.finalize!
        instance.get_region_config("us-east-1")
      end

      its("ami") { should == "child" }
    end

    describe "merging" do
      let(:first)  { described_class.new }
      let(:second) { described_class.new }

      it "devrait fusionner les balises et block_device_mappings" do
        first.tags["one"] = "one"
        second.tags["two"] = "two"
        first.package_tags["three"] = "three"
        second.package_tags["four"] = "four"
        first.block_device_mapping = [{:one => "one"}]
        second.block_device_mapping = [{:two => "two"}]

        third = first.merge(second)
        third.tags.should == {
          "one" => "one",
          "two" => "two"
        }
        third.package_tags.should == {
          "three" => "three",
          "four" => "four"
        }
        third.block_device_mapping.index({:one => "one"}).should_not be_nil
        third.block_device_mapping.index({:two => "two"}).should_not be_nil
      end
    end
  end
end
