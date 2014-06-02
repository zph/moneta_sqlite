# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moneta_sqlite/version'

Gem::Specification.new do |spec|
  spec.name          = "moneta_sqlite"
  spec.version       = MonetaSqlite::VERSION
  spec.authors       = ["Zander Hill"]
  spec.email         = ["Zander@civet.ws"]
  spec.summary       = %q{Adds keys method to Moneta SQLite}
  spec.description   = %q{Adds keys method to Moneta SQLite.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "moneta"
  sqlite = if defined?(JRUBY_VERSION)
             "jdbc-sqlite3"
           else
             "sqlite3"
           end
  spec.add_dependency sqlite
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
