# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nwcopy/version"

Gem::Specification.new do |s|
  s.name        = "nwcopy"
  s.version     = Nwcopy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Josh Kleinpeter"]
  s.email       = ["josh@kleinpeter.org"]
  s.homepage    = ""
  s.summary     = %q{network copy & paste.}
  s.description = %q{Uses your Dropbox folder to facilitate copy and pasting between machines. More awesomesauce to come.}

  s.add_dependency 'multipart-post'
  s.add_dependency 'gist'
  s.add_dependency 'json'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
