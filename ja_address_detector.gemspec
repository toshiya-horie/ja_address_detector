lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ja_address_detector/version"

Gem::Specification.new do |spec|
  spec.name          = "ja_address_detector"
  spec.version       = JaAddressDetector::VERSION
  spec.authors       = ["Toshiya Horie"]
  spec.email         = ["toshiya.horie@gmail.com"]

  spec.summary       = "Detect japanese address from any text."
  spec.description   = spec.summary
  spec.homepage      = "https://aumo.jp/"
  spec.license       = "UNLICENSED"

  spec.metadata["allowed_push_host"] = "http://mygemserver.com"

  spec.metadata["homepage_uri"] = spec.homepage
#  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
#  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rubytree', '~> 1.0'
  spec.add_dependency 'rubyzip', '~> 1.2.3'
  spec.add_dependency 'download', '~> 1.1.0'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

end
