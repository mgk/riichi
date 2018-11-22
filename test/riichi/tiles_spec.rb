require 'spec_helper'

describe Tiles do

  to_tile = lambda { |str| Tile.from_s(str) }
  to_tiles = lambda { |s| Tiles.from_s(s) }

  describe "from_s" do
    it "initilizes sorted tiles from a string" do
      tiles = Tiles.from_s("1s 2s Ww").tiles
      tiles.must_equal(%w(1s 2s Ww).map { |s| Tile.from_s(s)} )
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
        ["Ww Ew Ww Ww",      "Ww Ww",          "Ew Ww"],
        ["1p",               "2p",             "1p"],
        ["1p 8p 9p",         "Ww Ew Nw Wd",    "1p 8p 9p"],
      ].map { |test| test.map(&to_tiles) }

      test_cases.each do |minuend, subtrahend, difference|
        (minuend - subtrahend).must_equal(difference)
      end
    end
  end

  describe "pung?" do
    it "is true with three matching tiles" do
      [%w[5s 5s 5s], %w[Wd Wd Wd]].each do |strings|
        set = strings.map(&to_tile)
        Tiles.pung?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [%w[5s 5s 6s], %w[1m 2m 3m], %w[2p Gd Gd]].each do |strings|
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
        %w[Wd Wd Wd]
      ].each do |strings|
        set = strings.map(&to_tile)
        Tiles.chow?(set).must_equal false
      end
    end
  end

  describe "arrangements" do
    it "determines all chows and pungs in tiles" do
      test_cases = [
        ["",                      []  ],
        ["Ww Ww Nw Wd 1p 2p 4p",  []  ],
        ["1p 2p 3p",              [["1p 2p 3p"]] ],
        ["1p 2p 3p 4p",           [["1p 2p 3p"], ["2p 3p 4p"]]  ],
        ["1p 1p 2p 3p",           [["1p 2p 3p"]]  ],
        ["1p 1p 1p 2p 3p 4p",     [["1p 2p 3p"], ["1p 1p 1p", "2p 3p 4p"]]  ],

        ["2m 2m 3m 3m 4m 4m",     [["2m 3m 4m", "2m 3m 4m"]]  ],
        ["2m 2m 3m 3m 4m 4m 5m",
          [
            ["2m 3m 4m", "2m 3m 4m"],
            ["2m 3m 4m", "3m 4m 5m"],

          ]
        ],

        ["1p 3p 9p 3s 7s 8s 8s 8s 9s 1m 2m 3m 6m Sw",
          [
            ["7s 8s 9s", "1m 2m 3m"],
            ["8s 8s 8s", "1m 2m 3m"],
          ]
        ],

        ["2p 3p 4p 5p 5p 5p 6p 6p 7p 8p 9p 6m Ew Rd",
          [
            ["2p 3p 4p", "5p 5p 5p", "6p 7p 8p"],
            ["2p 3p 4p", "5p 5p 5p", "7p 8p 9p"],
            ["2p 3p 4p", "5p 6p 7p"],
            ["3p 4p 5p", "5p 6p 7p"],
            ["3p 4p 5p", "6p 7p 8p"],
            ["3p 4p 5p", "7p 8p 9p"],
            ["4p 5p 6p", "5p 6p 7p"],
            ["4p 5p 6p", "6p 7p 8p"],
            ["4p 5p 6p", "7p 8p 9p"],
          ]
        ],

      ].map do |input, expected_arrangements|
        arrangements = expected_arrangements.map do |arrangement|
          arrangement.map(&to_tiles).map(&:tiles)
        end
        [Tiles.from_s(input).tiles, arrangements]
      end

      test_cases.each do |tiles, expected|
        actual = Tiles.arrangements(tiles)
        leftovers = Tiles.diff(tiles, actual)
        leftovers.combination(3) do |group|
          Tiles.set?(group).must_equal(false, "missed set #{group} for #{tiles}")
        end

        actual.sort.must_equal(expected.sort, "input: #{tiles}")
      end
    end

    RIICHI_TEST_HAND_COUNT = (ENV["RIICHI_TEST_HAND_COUNT"] || "1000").to_i

    it "random hand test - (#{RIICHI_TEST_HAND_COUNT} iterations)" do
      RIICHI_TEST_HAND_COUNT.times do |n|
        hand = Tile.deck.sample(14)

        Tiles.arrangements(hand).each do |arrangement|
          # all sets in the arrangement must really be sets
          arrangement.each do |set|
            Tiles.set?(set).must_equal(true, "n=[#{n}] bad set #{set} for #{hand}")
          end

          # all arrangement tiles exist in the hand
          Tiles.diff(arrangement.sum([]), hand)
          .must_be_empty("too many tiles in arrangement #{arrangement} for #{hand}")

          # the leftovers contain no sets
          leftovers = Tiles.diff(hand, arrangement)
          leftovers.combination(3) do |group|
            Tiles.set?(group).must_equal(false, "n=[#{n}] missed set #{group} for #{hand}")
          end
        end
      end
    end
  end

  describe "initial_chow" do
    it "works" do
      tiles = Tiles.from_s("7s 8s 8s 8s 9s 1m").tiles
      Tiles.initial_chow(tiles).must_equal(Tiles.from_s("7s 8s 9s").tiles)
    end
  end

end