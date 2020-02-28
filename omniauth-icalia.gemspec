
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-icalia/version'

Gem::Specification.new do |spec|
  spec.authors       = ['Roberto Quintanilla']
  spec.email         = ['vov@icalialabs.com']
  spec.description   = %q{Official Omniauth Strategy for Icalia.}
  spec.summary       = %q{Official Omniauth Strategy for Icalia.}
  spec.homepage      = 'https://github.com/IcaliaLabs/omniauth-icalia'
  spec.license       = 'MIT'
  
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.files         = `git ls-files -- lib/* *.md *.gemspec *.txt Rakefile`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.name          = 'omniauth-icalia'
  spec.require_paths = ['lib']
  spec.version       = Omniauth::Icalia::VERSION

  spec.add_dependency 'omniauth', '~> 1.5'
  spec.add_dependency 'omniauth-oauth2', '>= 1.4.0', '< 2.0'
  spec.add_dependency 'icalia-sdk-event-core', '~> 0.3', '>= 0.3.5'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'capybara', '~> 3.0', '>= 3.0.0'
  spec.add_development_dependency 'sinatra', '~> 2.0', '>= 2.0.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
