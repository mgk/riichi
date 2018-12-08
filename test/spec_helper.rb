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

require 'minitest-spec-context'

def hand_counter(tiles, melds: [])
  hand = Hand.new(tiles, melds: melds)

  hand.complete_arrangements.length.must_equal(1, "too many wins: #{hand}")

  # Find the first "describe XXX" where XXX is a HandCounter
  cls = self.class.ancestors.find do |a|
    a.respond_to?(:desc) &&
      a.desc.kind_of?(Class) &&
      a.desc <= Riichi::Score::HandCounter
  end.desc

  cls.new(hand, hand.complete_arrangements.first)
end

def yaku_count(tiles, melds: [])
  hand_counter(tiles, melds: melds).count
end
