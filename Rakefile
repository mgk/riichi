require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include 'coverage'

Rake::TestTask.new(:default) do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/**/*_spec.rb']
end
desc 'Run tests'
