require 'bundler/setup'

require 'riichi'
Tile = Riichi::Tile

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
