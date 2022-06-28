$:.unshift File.expand_path("../lib", __FILE__)
require "vagrant-aws/version"

Gem::Specification.new do |s|
  s.name          = "vagrant-aws"
  s.version       = VagrantPlugins::AWS::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = "MIT"
  s.authors       = "Mitchell Hashimoto"
  s.email         = "mitchell@hashicorp.com"
  s.homepage      = "http://www.vagrantup.com"
  s.summary       = "Enables Vagrant to manage machines in EC2 and VPC."
  s.description   = "Enables Vagrant to manage machines in EC2 and VPC."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "vagrant-aws"

  s.add_runtime_dependency "fog", "~> 1.22"
  s.add_runtime_dependency "iniparse", "~> 1.4", ">= 1.4.2"

  s.add_development_dependency "rake"
  # rspec 3.4 to mock File
  s.add_development_dependency "rspec", "~> 3.4"
  s.add_development_dependency "rspec-its"

  # Le bloc de code suivant détermine les fichiers qui doivent être inclus dans la gemme. Pour ce faire, il lit tous les fichiers du répertoire
  # où se trouve cette gemspec et analyse les fichiers ignorés du gitignore.
  # Notez que toute la syntaxe gitignore(5) n'est pas prise en charge, en particulier le "!" syntaxe,
  # mais cela devrait généralement fonctionner correctement.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
  all_files.reject! { |file| [".", ".."].include?(File.basename(file)) }
  gitignore_path = File.join(root_path, ".gitignore")
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignorez tous les répertoires, le gemspec ne se soucie que des fichiers
    next true if File.directory?(file)

    # Ignorez tous les chemins qui correspondent à quoi que ce soit dans le gitignore. 
    # Nous faisons deux tests ici :   
    #   - Tout d'abord, testez pour voir si le chemin entier correspond au gitignore.
    #   - Deuxièmement, correspond si le nom de base le fait, cela fait en sorte que des choses comme '.DS_Store'
    #   correspondent également aux sous-répertoires (même comportement que git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
        File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  s.files         = unignored_files
  s.executables   = unignored_files.map { |f| f[/^bin\/(.*)/, 1] }.compact
  s.require_path  = 'lib'
end
