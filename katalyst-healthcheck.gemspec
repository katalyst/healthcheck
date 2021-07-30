require_relative "lib/katalyst/healthcheck/version"

Gem::Specification.new do |spec|
  spec.name        = "katalyst-healthcheck"
  spec.version     = Katalyst::Healthcheck::VERSION
  spec.authors     = ["Katalyst Interactive"]
  spec.email       = ["admin@katalyst.com.au"]
  spec.homepage    = "https://github.com/katalyst/katalyst-healthcheck"
  spec.summary     = "Health check routes and functions"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://github.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4", ">= 6.1.4.1"
end
