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

def hand_counter(hand)
  hand.complete_arrangements.length.must_equal(1, "bad test: #{hand}")

  # Find the innermost "describe XXX" where XXX is a HandCounter
  cls = self.class.ancestors.find do |a|
    a.respond_to?(:desc) &&
      a.desc.kind_of?(Class) &&
      a.desc <= Riichi::Score::HandCounter
  end.desc

  cls.new(hand, hand.complete_arrangements.first)
end

def yaku_count(hand_or_tiles, melds: [], bakaze: nil, jikaze: nil)
  hand = case hand_or_tiles
  when Hand then hand_or_tiles
  else Hand.new(hand_or_tiles, melds: melds, bakaze: bakaze, jikaze: jikaze)
  end

  hand_counter(hand).count
end
