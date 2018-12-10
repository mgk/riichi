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

end