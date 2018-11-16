require 'spec_helper'

describe Tiles do

  to_tile = lambda { |str| Tile.from_s(str) }
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

  describe "pung?" do
    it "is true with three matching tiles" do
      [%w[5s 5s 5s], %w[F F F]].each do |strings|
        set = strings.map(&to_tile)
        Tiles.pung?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [%w[5s 5s 6s], %w[1m 2m 3m], %w[2p F F]].each do |strings|
        set = strings.map(&to_tile)
        Tiles.pung?(set).must_equal false
      end
    end
  end

  describe "chow?" do
    it "is true with suited tiles in ascending order" do
      [%w[1s 2s 3s], %w[5p 6p 7p]].each do |strings|
        set = strings.map(&to_tile)
        Tiles.chow?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [
        %w[5s 7s 6s],
        %w[7s 6s 5s],
        %w[2m 2m 3m],
        %w[F F F]
      ].each do |strings|
        set = strings.map(&to_tile)
        Tiles.chow?(set).must_equal false
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

        # ["1p 3p 9p 3s 7s 8s 8s 8s 9s 1m 2m 3m 6m S",
        #   ["7s 8s 9s", "8s 8s 8s", "1m 1m 3m"]]

        # 5p 7p 8p 9p 1s 1s 3s 5s 1m 2m 3m 3m 4m N
      ].map do |input, expected_sets|
        [Tiles.from_s(input), expected_sets.map(&to_tiles).map(&:tiles)]
      end

      test_cases.each do |tiles, expected|
        tiles.sets.must_equal(expected, "input: #{tiles}")
      end
    end

    it "random hand test: all returned sets are really sets" do
      10000.times do |n|
        hand = Tiles.new(Tile.deck.sample(14))
        hand.sets.each do |set|
          Tiles.set?(set).must_equal(true, "n=[#{n}] bad set #{set} for #{hand}")
        end
      end
    end

   it "random hand test: all sets are found" do
      0.times do |n|
        hand = Tiles.new(Tile.deck.sample(14))
        hand.sets.each do |set|
          Tiles.set?(set).must_equal(true, "n=[#{n}] bad set #{set} for #{hand}")
          (hand - Tiles.new(set)).tiles.combination(3) do |group|
            Tiles.set?(group).must_equal(false, "n=[#{n}] missed set #{set} for #{hand}")
          end
        end
      end
    end
  end

  describe "chow_start?" do
    it "works" do
      tiles = Tiles.from_s("7s 8s 8s 8s 9s 1m").tiles
      Tiles.chow_start?(tiles).must_equal(true)
    end
  end

end