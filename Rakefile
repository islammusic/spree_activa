require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'rake/testtask'
require 'spree/testing_support/extension_rake'

RSpec::Core::RakeTask.new

task :default do
  if Dir["spec/dummy"].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir("../../")
  end
  Rake::Task[:spec].invoke
end

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'spree_activa'
  Rake::Task['extension:test_app'].invoke
end

desc "Run the unit test suite"
task :default => 'test:units'
task :test => 'test:units'

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*_test.rb'
    t.ruby_opts << '-rubygems -w'
    t.libs << 'test'
    t.verbose = true
  end

  Rake::TestTask.new(:remote) do |t|
    t.pattern = 'test/remote/**/*_test.rb'
    t.ruby_opts << '-rubygems -w'
    t.libs << 'test'
    t.verbose = true
  end
end
