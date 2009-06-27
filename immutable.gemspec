spec = Gem::Specification.new do |s|
  s.name     = "immutable"
  s.version  = "0.3"
  s.author   = "Garry Dolley"
  s.email    = "gdolley@ucla.edu"
  s.homepage = "http://github.com/up_the_irons/immutable/tree/master"
  s.platform = Gem::Platform::RUBY
  s.summary  = "Declare methods as immutable, somewhat like Java's 'final' keyword but still allowing child classes to override."

  s.files    = ['lib/immutable.rb', 'spec/immutable_spec.rb', 'immutable.gemspec', 'README', 'COPYING']
  s.has_rdoc = false
end
