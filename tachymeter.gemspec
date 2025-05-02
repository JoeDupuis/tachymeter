# frozen_string_literal: true

require_relative "lib/tachymeter/version"

Gem::Specification.new do |spec|
  spec.name = "tachymeter"
  spec.version = Tachymeter::VERSION
  spec.authors = [ "Joé Dupuis" ]
  spec.email = [ "joe@dupuis.io" ]

  spec.summary = "Rails benchmarking tool."
  spec.homepage = "https://github.com/JoeDupuis/tachymeter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/JoeDupuis/tachymeter/blob/main/CHANGELOG.md"

  spec.files = Dir['lib/**/*.rb', 'Rakefile', 'README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.bindir = "exe"
  spec.executables = [ "tachymeter" ]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "rails"
end
