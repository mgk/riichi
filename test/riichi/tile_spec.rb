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

  describe "pairs" do
    it "determines the pairs and leftovers" do
      [
        ["1m 2m",             [],                 "1m 2m"],
        ["1m 1m",             ["1m 1m"],          ""],
        ["1m 1m 2m",          ["1m 1m"],          "2m"],
        ["1m 1m 2m 2m",       ["1m 1m", "2m 2m"], ""],
        ["1m 1m 2s 3s",       ["1m 1m"],          "2s 3s"],

      ].map do |tiles, pairs, leftovers|
        pairs = pairs.map { |s| Tile.to_tiles(s) }
        [Tile.to_tiles(tiles), pairs, Tile.to_tiles(leftovers)]
      end
      .each do |tiles, pairs, leftovers|
        Tile.pairs(tiles).must_equal([pairs, leftovers], tiles)
      end
    end
  end

  describe "tatsu?" do
    it "reports tiles form a tatsu" do
      ["1m 2m", "2p 4p", "3s 4s", "7s 9s",].each do |tile_string|
        tiles = Tile.to_tiles(tile_string)
        tiles[0].tatsu?(tiles[1]).must_equal(true, tile_string)
        tiles[1].tatsu?(tiles[0]).must_equal(true, tile_string)
      end
    end
    it "reports tiles do NOT form a tatsu" do
      ["1m 1m", "2p 5p", "5s 9s", "Rd Wd"].each do |tile_string|
        tiles = Tile.to_tiles(tile_string)
        tiles[0].tatsu?(tiles[1]).must_equal(false, tile_string)
        tiles[1].tatsu?(tiles[0]).must_equal(false, tile_string)
      end
    end
  end

  describe "tiles_that_complete_chow?" do
    it "reports tiles that complete the chow" do
      [
        ["1m 2m", "3m"],
        ["2s 3s", "1s 4s"],
        ["8p 9p", "7p"],
        ["6p 8p", "7p"],
        ["7p 8p", "6p 9p"],
      ].each do |tiles, expected|
        Tile.tiles_that_complete_chow(Tile.to_tiles(tiles))
      end
    end
    it "reports that no tiles complete the chow" do
      [
        ["1m 1m", ""],
        ["2s 5s", ""],
        ["1p 9p", ""],
      ].each do |tiles, expected|
        Tile.tiles_that_complete_chow(Tile.to_tiles(tiles))
      end
    end
  end

  describe "arrangements" do
    it "determines all chows, pungs, and complete special hands in tiles" do
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

        ["1m 2p 3s 8p 8p 9m 9m Ew Sw Ww Nw Wd Gd Rd", []],

        ["1s 1s - 2p 2p - 3m 3m - Ww Ww - Gd Gd - Rd Rd - Wd Wd",
          [
            ["3m 3m","1s 1s", "2p 2p", "Ww Ww", "Wd Wd", "Gd Gd", "Rd Rd"]
          ]
        ],

        # chii toitsu - waiting on last pair
        ["1s 1s - 2p 2p - 3m 3m - Ww Ww - Gd Gd - Rd Rd - Wd",
          [
            ["3m 3m","1s 1s", "2p 2p", "Ww Ww", "Gd Gd", "Rd Rd"]
          ]
        ],

        # chii toitsu - complete
        ["1s 1s - 2p 2p - 3m 3m - Ww Ww - Gd Gd - Rd Rd - Wd Wd",
          [
            ["3m 3m","1s 1s", "2p 2p", "Ww Ww", "Wd Wd", "Gd Gd", "Rd Rd"]
          ]
        ],

        # chii toitsu - cannot have a kong in chi toi
        ["1s 1s - 2p 2p - 3m 3m - Ww Ww - Gd Gd - Rd Rd - Rd Rd ",
          [["Rd Rd Rd"]]
        ],

        # # chii toitsu - only 6 of 7 pairs
        ["5m 9p --- 1m 1m  2s 2s  3p 3p  4p 4p  5s 5s  6m 6m", []],

        # 13 orphans - one of each - 13 sided wait!
        [   "1m 9m 1s 9s 1p 9p Ew Sw Ww Nw Wd Gd Rd", [
          %w(1m 9m 1s 9s 1p 9p Ew Sw Ww Nw Wd Gd Rd)
        ]],

        # 13 orphans - one pair, one sided wait
        [   "1m 9m 1s 9s 1p 9p Ew Sw Ww Nw Wd Gd Gd", [
          %w(1m 9m 1s 9s 1p 9p Ew Sw Ww Nw Wd) + ["Gd Gd"]
        ]],

        # 13 orphans? - two pairs, nope
        [   "1m 9m 1s 9s 1p 9p Ew Sw Ww Nw Wd Wd Gd Gd", []],

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
          if arrangement.length.between?(6, 7)
            arrangement.each do |pair|
              Tile.pair?(pair).must_equal(true, "n=[#{n}] bad pair #{pair} for #{hand}")
            end
          else
            arrangement.each do |set|
              Tile.set?(set).must_equal(true, "n=[#{n}] bad set #{set} for #{hand}")
            end
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