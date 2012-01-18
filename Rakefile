require 'fileutils'

NAME = Dir['*.gemspec'].first

def gemspec
  @gemspec ||= eval(File.read(NAME), binding, NAME)
end

desc "Build the gem"
task :gem => :gemspec do
  sh "gem build #{NAME}"
  FileUtils.mkdir_p 'pkg'
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", 'pkg'
end

desc "Install the gem locally"
task :install => :gem do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version} --no-rdoc --no-ri}
end

desc "Generate the gemspec"
task :generate do
  puts gemspec.to_ruby
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:spec)

task :default => :spec
