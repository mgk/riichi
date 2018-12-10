require 'spec_helper'

describe Hand do

  describe "complete?" do
    it "returns false for incomplete hands" do
      [
        ["1s", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p", "4p 4p 4p"]],
        ["1s 1s 1s 1s", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p"]],
        ["1s 2s", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p", "Gd Gd Gd"]],
        ["1s 1s 1s Wd", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p"]],
        ["4p 4p - 1p 1p - 2p 2p - Ew Ew - Sw Sw - Ww Ww - Gd", [""]],
      ]
      .each do |tiles, melds|
        Hand.new(tiles, melds: melds.map { |m| Tile.to_tiles(m) })
          .complete?.must_equal(false, "'#{tiles}' is not complete")
      end
    end
    it "returns true for complete hands" do
      [
        "1s 1s",
        "1s 1s 1s Wd Wd",
        "1s 2s 3s 4s 5s 6s 7s 7s 7s Ww Ww",
        "4p 4p - 1p 1p - 2p 2p - Ew Ew - Sw Sw - Ww Ww - Nw Nw",
      ]
      .each do |tiles|
        tiles = Tile.to_tiles(tiles)
        num_melds = (14 - tiles.length) / 3
        melds = (1..num_melds).map do |num|
          [Tile.get(suit: :pinzu, rank: num)] * 3
        end
        Hand.new(tiles, melds: melds)
          .complete?.must_equal(true, "'#{tiles}' is complete")
      end
    end
  end

  describe "waiting_tiles" do
    it "reports tiles that complete the hand with given arrangement" do
      [
        ["1s 1s 1s Wd",          ["1s 1s 1s"], "Wd"],
        ["1s 1s 1s 3m 2m Nw Nw", ["1s 1s 1s"], "1m 4m"],
        ["1s 1s 1s 3m 2m Nw Nw", ["1s 1s 1s"], "1m 4m"],
      ].map do |tiles, arrangement, waiting_tiles|
        tiles = Tile.to_tiles(tiles)
        num_melds = (13 - tiles.length) / 3
        melds = (1..num_melds).map do |num|
          [Tile.get(suit: :pinzu, rank: num)] * 3
        end
        [Hand.new(tiles, melds: melds),
          arrangement.map { |s| Tile.to_tiles(s) },
          Tile.to_tiles(waiting_tiles)]
      end.each do |hand, arrangement, waiting_tiles|
        hand.waiting_tiles(arrangement).must_equal(waiting_tiles, hand)
      end
    end
  end

  describe "waits" do
    it "reports list of winning tiles for tenpai hands" do
      [
        ["1s 1s 1s--2p 2p 2p--Wd Wd Wd--Ew Ew Ew-- Sw",
          [
            [["1s 1s 1s", "2p 2p 2p", "Wd Wd Wd", "Ew Ew Ew"], "Sw"]
          ]
        ],
      ].map do |hand, waits|
        hand = Hand.new(hand)
        waits = waits.map do |arrangement, waiting_tiles|
          [arrangement.map { |s| Tile.to_tiles(s) }.sort, Tile.to_tiles(waiting_tiles)]
        end
        [hand, waits]
      end.each do |hand, waits|
        hand.waits.must_equal(waits, hand)
      end
    end
  end

  describe "complete?" do
    it "reports true for complete hands" do
      [
        's111 p222 m333 GGG RR',
        '1s 1s 1s - 2p 2p 2p - 3m 3m 3m - Gd Gd Gd - Rd Rd',
        '1s 1s - 2p 2p - 3s 3s - 4m 4m - 5s 5s - 6p 6p - 7s 7s',
      ].each do |tiles|
        hand = Hand.new(tiles)
        hand.complete?.must_equal(true, tiles)
        hand.complete_arrangements.length.must_equal(1)
      end
    end

    it "reports false for incomplete hands" do
      [
        '1s 1s - 2p 2p - 3s 3s - 4m 4m - 5s 5s -- 6s 6s 6s 6s',
      ].each do |tiles|
        Hand.new(tiles).complete?.must_equal(false, tiles)
      end
    end
  end

  describe "complete_arrangements" do
    it "reports the complete arrangements" do
      [
        ["RR", ["eee sss www nnn"], [["RR"]] ],
      ].each do |tiles, melds, arrangements|
        actual = Hand.new(tiles, melds: melds).complete_arrangements
        expected = arrangements.map do |arrangement|
          arrangement.map { |set| Tile.to_tiles(set) }
        end
        actual.must_equal(expected, [tiles, melds])
      end
    end
  end

  describe "mixed_triple_chow? (san shoku dojun)" do
    it "reports false when not present" do
      ['1s 2s 3s - 1m 2m 3m - 2p 3p 4p - 3m 3m 3m -7s 7s',
        '1s 2s 3s - 1m 2m 3m - 1m 2m 3m - 5m 5m 5m -7s 7s'].each do |hand|
        hand = Hand.new(hand)
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.mixed_triple_chow?(arrangement).must_equal(false, hand)
      end
    end

    it "reports true when present for closed hands" do
      ['1s 2s 3s - 1m 2m 3m - 1p 2p 3p - 3m 3m 3m -7s 7s',
        '4s 5s 6s - 4m 5m 6m - 4p 5p 6p - Rd Rd Rd - Ew Ew'].each do |hand|
        hand = Hand.new(hand)
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.mixed_triple_chow?(arrangement).must_equal(true, hand)
      end
    end

    it "reports true when present for open hands" do
      [
        ['1s 2s 3s - 1m 2m 3m - 1p 2p 3p', '7s 7s 7s'],
        ['4s 5s 6s - 4m 5m 6m - Rd Rd Rd', '4p 5p 6p'],
      ].each do |tiles, meld|
        hand = Hand.new(tiles + ' Sw Sw', melds: [Tile.to_tiles(meld)])
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.mixed_triple_chow?(arrangement).must_equal(true, hand)
      end
    end
  end

  describe "ittsu?" do
    it "reports 0 when straight in suit is not complete" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7m 8m 9m - Gd Gd Gd - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.ittsu?(arrangement).must_equal(false, hand)
      end
    end

    it "reports 0 when not all chows are present" do
      hand = Hand.new("1p 2p 3p - 3p 4p 5p - 6p 7p 8p - 7p 8p 9p - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.ittsu?(arrangement).must_equal(false, hand)
      end
    end

    it "reports 2 when closed" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7p 8p 9p - Gd Gd Gd - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.ittsu?(arrangement).must_equal(true, hand)
      end
    end

    it "reports 1 when open" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7p 8p 9p - 7m 7m",
        melds: [Tile.to_tiles("Gd Gd Gd")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.ittsu?(arrangement).must_equal(true, hand)
      end
    end
  end

  describe "chanta?" do
    it "reports false when not all sets include outside tile" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7m 8m 9m - Gd Gd Gd - 9m 9m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta?(arrangement).must_equal(false, hand)
      end
    end

    it "reports false when atama is not outside tiles" do
      hand = Hand.new("1p 2p 3p - 3p 4p 5p - 6p 7p 8p - 7p 8p 9p - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta?(arrangement).must_equal(false, hand)
      end
    end

    it "reports false when all no honours tiles (junchan)" do
      hand = Hand.new("1p 2p 3p - 9p 9p 9p - 1s 2s 3s - 1s 1s 1s - 9m 9m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta?(arrangement).must_equal(false, hand)
      end
    end

    it "reports falsewhen all outside tiles (honroto)!" do
      hand = Hand.new("1p 1p 1p - 9p 9p 9p - Nw Nw Nw - 1s 1s 1s - Rd Rd")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta?(arrangement).must_equal(false, hand)
      end
    end

    it "reports true when present in closed hand" do
      hand = Hand.new("1p 2p 3p 1p 2p 3p 7p 8p 9p - Gd Gd Gd - Nw Nw")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta?(arrangement).must_equal(true, hand)
      end
    end

    it "reports true when present in open hand" do
      hand = Hand.new("1p 2p 3p 1p 2p 3p 7p 8p 9p - 1m 1m",
        melds: [Tile.to_tiles("Gd Gd Gd")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta?(arrangement).must_equal(true, hand)
      end
    end
  end

  describe "san_anko?" do
    it "reports false with only 2 pungs" do
      hand = Hand.new("1m 1m 1m - 2m 2m 2m - 3m 4m 5m - 5m 6m 7m - Nw Nw")
      hand.complete?.must_equal(true, hand)
      hand.complete_arrangements.each do |arrangement|
        hand.san_anko?(arrangement).must_equal(false, hand)
      end
    end

    it "reports false with 2 closed pungs and 1 open" do
      hand = Hand.new("1m 1m 1m - 2m 2m 2m - 3m 4m 5m - Nw Nw",
          melds: [Tile.to_tiles("Gd Gd Gd")])
      hand.complete?.must_equal(true, hand)
      hand.complete_arrangements.each do |arrangement|
        hand.san_anko?(arrangement).must_equal(false, hand)
      end
    end

    it "reports true with 3 concealed pungs" do
      hand = Hand.new("1m 1m 1m - 2m 2m 2m - 4m 4m 4m - 5m 6m 7m - Nw Nw")
      hand.complete?.must_equal(true, hand)
      hand.complete_arrangements.each do |arrangement|
        hand.san_anko?(arrangement).must_equal(true, hand)
      end
    end

    it "reports true with 3 concealed pungs and 1 open pung" do
      hand = Hand.new("1m 1m 1m - 2m 2m 2m - 4s 4s 4s - Nw Nw",
          melds: [Tile.to_tiles("Gd Gd Gd")])
      hand.complete?.must_equal(true, hand)
      hand.complete_arrangements.each do |arrangement|
        hand.san_anko?(arrangement).must_equal(true, hand)
      end
    end

  end
end