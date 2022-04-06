# frozen_string_literal: true

require_relative "lib/katalyst/healthcheck/version"

Gem::Specification.new do |spec|
  spec.name     = "katalyst-healthcheck"
  spec.version  = Katalyst::Healthcheck::VERSION
  spec.authors  = ["Katalyst Interactive"]
  spec.email    = ["admin@katalyst.com.au"]
  spec.homepage = "https://github.com/katalyst/katalyst-healthcheck"
  spec.summary  = "Health check routes and functions"
  spec.license  = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "activemodel", ">= 6"
  spec.add_dependency "redis", ">= 3.3.5"
  spec.add_dependency "redlock", ">= 1.2.2"
end
