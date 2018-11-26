require 'spec_helper'

describe Tile do

  describe "to_tile" do
    it "works for a wind" do
      t = Tile.to_tile('Ww')
      t.suit.must_be_nil
      t.rank.must_be_nil
      t.str.must_equal 'Ww'
      t.wind.must_equal :west
      t.dragon.must_be_nil
    end

    it "works for a suited tile" do
      t = Tile.to_tile('1p')
      t.suit.must_equal :pinzu
      t.rank.must_equal 1
      t.str.must_equal '1p'
      t.wind.must_be_nil
      t.dragon.must_be_nil
    end

  end

  describe "diff" do
    it "removes the first occurrence of each Tile" do
      test_cases = [
        # minuend            subtrahend        difference
        ["1p 2p 3p",         "2p 3p",          "1p"],
        ["1p 2p 2p",         "2p",             "1p 2p"],
        ["Ww Ew Ww Ww",      "Ww Ww",          "Ew Ww"],
        ["1p",               "2p",             "1p"],
        ["1p 8p 9p",         "Ww Ew Nw Wd",    "1p 8p 9p"],
      ].map { |test| test.map { |s| Tile.to_tiles(s) } }

      test_cases.each do |minuend, subtrahend, difference|
        Tile.diff(minuend, subtrahend).must_equal(difference)
      end
    end
  end

  describe "Comparable" do
    it "should sort properly" do
      unsorted = '1m 2p 3s 2s 2m 1s 1m Wd Wd Gd Nw Ew Ww Sw Rd'
      sorted   = '1m 1m 2m 1s 2s 3s 2p Ew Sw Ww Nw Wd Wd Gd Rd'

      Tile.to_tiles(unsorted).sort.must_equal(Tile.to_tiles(sorted))
    end
  end

  describe "pung?" do
    it "is true with three matching tiles" do
      [%w[5s 5s 5s], %w[Wd Wd Wd]].each do |strings|
        set = strings.map { |s| Tile.to_tile(s) }
        Tile.pung?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [%w[5s 5s 6s], %w[1m 2m 3m], %w[2p Gd Gd]].each do |strings|
        set = strings.map { |s| Tile.to_tile(s) }
        Tile.pung?(set).must_equal false
      end
    end
  end

  describe "chow?" do
    it "is true with suited tiles in ascending order" do
      [%w[1s 2s 3s], %w[5p 6p 7p]].each do |strings|
        set = strings.map { |s| Tile.to_tile(s) }
        Tile.chow?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [
        %w[5s 7s 6s],
        %w[7s 6s 5s],
        %w[2m 2m 3m],
        %w[Wd Wd Wd]
      ].each do |strings|
        set = strings.map { |s| Tile.to_tile(s) }
        Tile.chow?(set).must_equal false
      end
    end
  end

  describe "initial_chow" do
    it "works" do
      Tile.initial_chow(Tile.to_tiles("7s 8s 8s 8s 9s 1m"))
        .must_equal(Tile.to_tiles("7s 8s 9s"))
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
            ["1m 2m 3m", "7s 8s 9s"],
            ["1m 2m 3m", "8s 8s 8s"],
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
          arrangement.map { |array| Tile.to_tiles(array) }
        end
        [Tile.to_tiles(input), arrangements]
      end

      test_cases.each do |tiles, expected|
        actual = Tile.arrangements(tiles)
        leftovers = Tile.diff(tiles, actual)
        leftovers.combination(3) do |group|
          Tile.set?(group).must_equal(false, "missed set #{group} for #{tiles}")
        end

        actual.sort.must_equal(expected.sort, "input: #{tiles}")
      end
    end

    RIICHI_TEST_HAND_COUNT = (ENV["RIICHI_TEST_HAND_COUNT"] || "1000").to_i

    it "random hand test - (#{RIICHI_TEST_HAND_COUNT} iterations)" do
      RIICHI_TEST_HAND_COUNT.times do |n|
        hand = Tile.deck.sample(14)

        Tile.arrangements(hand).each do |arrangement|
          # all sets in the arrangement must really be sets
          arrangement.each do |set|
            Tile.set?(set).must_equal(true, "n=[#{n}] bad set #{set} for #{hand}")
          end

          # all arrangement tiles exist in the hand
          Tile.diff(arrangement.sum([]), hand)
          .must_be_empty("too many tiles in arrangement #{arrangement} for #{hand}")

          # the leftovers contain no sets
          leftovers = Tile.diff(hand, arrangement)
          leftovers.combination(3) do |group|
            Tile.set?(group).must_equal(false, "n=[#{n}] missed set #{group} for #{hand}")
          end
        end
      end
    end
  end

end