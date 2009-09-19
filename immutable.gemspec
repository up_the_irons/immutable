spec = Gem::Specification.new do |s|
  s.name        = "immutable"
  s.version     = "0.3"
  s.authors     = ["Garry Dolley", "Lucas de Castro"]
  s.email       = "gdolley@ucla.edu"
  s.homepage    = "http://github.com/up_the_irons/immutable/tree/master"
  s.description = "Declare methods as immutable."
  s.summary     = "Declare methods as immutable, somewhat like Java's 'final' keyword but still allowing child classes to override."
  s.files       = ['lib/immutable.rb', 'spec/immutable_spec.rb', 'immutable.gemspec', 'README', 'COPYING']
  s.has_rdoc    = false
end
