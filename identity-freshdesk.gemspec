$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "identity/freshdesk/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "identity-freshdesk"
  spec.version     = Identity::Freshdesk::VERSION
  spec.authors     = ["Marcin Koziej"]
  spec.email       = ["marcin@akcjademokracja.pl"]
  spec.homepage    = "https://github.com/the-open/identity-freshdesk"
  spec.summary     = "Freshdesk integration plugin for Identity"
  spec.description = "Create rules to run in Identity when members create or update tickets in Freshdesk"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'sidekiq', '~> 6.0'
  spec.add_dependency 'httpclient', '~> 2.8.3'
  spec.add_dependency "rails", "~> 5.2.2", ">= 5.2.2.1"

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'codecov'
end
