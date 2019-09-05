# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eml2html/version'

Gem::Specification.new do |spec|
  spec.name          = "eml2html"
  spec.version       = Eml2Html::VERSION
  spec.authors       = ["Bartłomiej Bułat"]
  spec.email         = ["bartek.bulat@gmail.com"]
  spec.description   = %q{eml2html executable for unpacking .eml files into html and attachments}
  spec.summary       = %q{eml2html executable for unpacking .eml files into html and attachments}
  spec.homepage      = "https://github.com/barthez/eml2html"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['eml2html']
  spec.require_paths = ["lib"]
  
  spec.required_ruby_version = '>= 2.3.0'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"

  spec.add_dependency "mail"
  spec.add_dependency "rubyzip"
end
