require 'bundler/setup'

require 'simplecov'
SimpleCov.command_name ARGV[1]&.sub('^test/lib/', '')
SimpleCov.start do
  add_filter '/test/'
end

require 'riichi'
Tile = Riichi::Tile
Hand = Riichi::Hand

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
