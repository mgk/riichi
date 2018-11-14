require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include 'coverage'

Rake::TestTask.new(:default) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_spec.rb'
end
desc 'Run tests'

Rake::TestTask.new(:bench) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_benchmark.rb'
end