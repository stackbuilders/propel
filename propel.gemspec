# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "propel/version"

Gem::Specification.new do |s|
  s.name        = "propel"
  s.version     = Propel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Justin Leitgeb"]
  s.email       = ["justin@stackbuilders.com"]
  s.homepage    = "http://github.com/stackbuilders/propel"
  s.summary     = "Propel helps you to follow best practices for pushing code to a remote git repo"
  s.description = <<-EOS
    The 'propel' script helps you to push your code to a remote server while following Continuous Integration (CI)
    best practices.  Propel first checks the CI server to make sure it's passing, and then runs the local spec
    suite and pushes changes.  If the remote server is failing, just have propel wait for it to pass while you get
    a coffee.
  EOS

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency('rake')
  s.add_dependency('json')

  s.add_development_dependency('rspec', ["~> 2.5.0"])
  s.add_development_dependency('stub_shell', ["0.0.2"])
end
