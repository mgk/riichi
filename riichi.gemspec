
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riichi/version'

Gem::Specification.new do |spec|
  spec.name          = "riichi"
  spec.version       = Riichi::VERSION
  spec.authors       = ["Michael Keirnan"]
  spec.email         = ["michael@keirnan.com"]

  spec.summary       = "Riichi hand calculator"
  spec.homepage      = "https://github.com/mgk/riichi"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mgk/riichi"
#    spec.metadata["changelog_uri"] = "CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|\.)}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "require_all", "~> 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
  spec.add_development_dependency "minitest-spec-context", "~> 0.0.3"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "yard", "~> 0.9.16"
end
