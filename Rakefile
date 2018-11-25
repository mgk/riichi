require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include ['coverage', 'doc']

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_spec.rb'
end

task :default => :test

Rake::TestTask.new(:bench) do |t|
  t.description = 'Run benchmarks'
  t.libs << 'test'
  t.pattern = 'test/**/*_benchmark.rb'
end
