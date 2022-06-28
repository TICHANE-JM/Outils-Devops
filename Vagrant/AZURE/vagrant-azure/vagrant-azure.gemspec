# encoding: utf-8
# Copyright (c) Microsoft Corporation. Tous les droits sont réservés.
# Sous licence sous la licence MIT. Voir Licence dans la racine du projet pour les informations de licence.
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-azure/version'

Gem::Specification.new do |s|
  s.name          = 'vagrant-azure'
  s.version       = VagrantPlugins::Azure::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = %w(Azure)
  s.description   = 'Activez Vagrant pour gérer les machines dans Microsoft Azure.'
  s.summary       = 'Activez Vagrant pour gérer les machines Windows et Linux dans Microsoft Azure.'
  s.homepage      = 'https://github.com/TICHANE-JM/Outils-Devops/edit/main/Vagrant/AZURE/vagrant-azure/'
  s.license       = 'MIT'
  s.require_paths = ['lib']
  s.files         = `git ls-files`.split("\n")
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'azure_mgmt_resources',  '~>0.10.0'
  s.add_runtime_dependency 'azure_mgmt_compute',    '~>0.10.0'
  s.add_runtime_dependency 'azure_mgmt_network',    '~>0.10.0'
  s.add_runtime_dependency 'azure_mgmt_storage',    '~>0.10.0'
  s.add_runtime_dependency 'haikunator',            '~>1.1'
  s.add_runtime_dependency 'highline',              '~>1.7'

  s.add_development_dependency 'rake',              '~>11.1'
  s.add_development_dependency 'rspec',             '~>3.4'
  s.add_development_dependency 'simplecov',         '~>0.11'
  s.add_development_dependency 'coveralls',         '~>0.8'
end
