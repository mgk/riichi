require 'spec_helper'

describe Tiles do

  to_tiles = lambda { |s| Tiles.from_s(s) }

  describe "from_s" do
    it "initilizes sorted tiles from a string" do
      tiles = Tiles.from_s("1s 2s W").tiles
      tiles.must_equal(%w(1s 2s W).map { |s| Tile.from_s(s)} )
    end
  end

  describe "to_s" do
    it "works" do
      Tiles.from_s("2s 1s").to_s.must_equal("1s 2s")
    end
  end

  describe "-" do
    it "removes the first occurrence of each Tile" do
      test_cases = [
        # minuend            subtrahend        difference
        ["1p 2p 3p",         "2p 3p",          "1p"],
        ["1p 2p 2p",         "2p",             "1p 2p"],
        ["W E W W",          "W W",            "E W"],
        ["1p",               "2p",             "1p"],
        ["1p 8p 9p",         "W E N S F B",    "1p 8p 9p"],
      ].map { |test| test.map(&to_tiles) }

      test_cases.each do |minuend, subtrahend, difference|
        (minuend - subtrahend).must_equal(difference)
      end
    end
  end

  describe "sets" do
    it "determines all chows and pungs in tiles" do
      test_cases = [
        ["",                   []],
        ["W W N B 1p 2p 4p",   []],
        ["1p 2p 3p",           ["1p 2p 3p"] ],
        ["1p 2p 3p 4p",        ["1p 2p 3p", "2p 3p 4p"] ],
        ["1p 1p 2p 3p",        ["1p 2p 3p"] ],
        ["1p 1p 2p 3p",        ["1p 2p 3p"] ],
        ["1p 1p 1p 2p 3p 4p",  ["1p 1p 1p", "1p 2p 3p", "2p 3p 4p"] ],
      ].map do |input, expected_sets|
        [Tiles.from_s(input), expected_sets.map(&to_tiles).map(&:tiles)]
      end

      test_cases.each do |tiles, expected|
        tiles.sets.must_equal(expected)
      end
    end
  end

end