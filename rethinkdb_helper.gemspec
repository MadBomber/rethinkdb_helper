# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rethinkdb_helper"
  spec.version       = '0.0.1'
  spec.authors       = ["Dewayne VanHoozer"]
  spec.email         = ["dvanhoozer@gmail.com"]

  spec.summary       = %q{A wrapper around the ruby rethinkdb gem}
  spec.description   = %q{The rethinkDB is an interesting NoSQL massively scalable open
    source project.  It may have some impact on the real-time processing
    community.  This little gem is just a convention wrapper around the official
    rethinkdb.  Its my conventions which are subject to change at a momments
    notice.  I would not use this gem if I were you.}
  spec.homepage      = "https://github.com/MadBomber/rethinkdb_helper"
  spec.license       = "You want it?  It's yours."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "rethinkdb", "~> 1.16"

end
