task :default => :spec

desc "run the specs"
task :spec do
  opts = File.read('spec/spec.opts').split("\n").join(' ') rescue ""
  ruby "spec/immutable_spec.rb #{opts}"
end
