# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atalanta/version'

Gem::Specification.new do |spec|
  spec.name          = "atalanta"
  spec.version       = Atalanta::VERSION
  spec.authors       = ["Josh Cooper"]
  spec.email         = ["josh@puppet.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{Execute Tasks}
  spec.description   = %q{Execute Tasks}
  spec.homepage      = "https://github.com/joshcooper/atalanta"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"

  spec.add_runtime_dependency "slop"
  spec.add_runtime_dependency "net-ssh"
  spec.add_runtime_dependency "ruby-progressbar"
  spec.add_runtime_dependency "concurrent-ruby"
  #spec.add_runtime_dependency "colorize"
  #spec.add_runtime_dependency "net-ssh"
  #spec.add_runtime_dependency "winrm"
end
