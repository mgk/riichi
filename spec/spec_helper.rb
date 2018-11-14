require 'bundler/setup'

require 'simplecov'
SimpleCov.command_name ARGV[1].sub('^spec/', '')
SimpleCov.start do
  add_filter '/spec/'
end

require 'riichi'
Tile = Riichi::Tile
Tiles = Riichi::Tiles

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
