require 'spec_helper'

describe Hand do

  def t(s); Tile.to_tiles(s); end

  describe "complete?" do
    it "returns false for incomplete hands" do
      [
        "",
        "1s",
        "1s 1s 1s",
        "1s 2s",
        "1s 1s 1s Wd Gd"
      ]
      .each do |tiles|
        Hand.new(tiles).complete?.must_equal(false, "'#{tiles}' is not complete")
      end
    end
    it "returns true for complete hands" do
      [
        "1s 1s",
        "1s 1s 1s Wd Wd",
        "1s 2s 3s 4s 5s 6s 7s 7s 7s Ww Ww",
      ]
      .each do |tiles|
        Hand.new(tiles).complete?.must_equal(true, "'#{tiles}' is complete")
      end
    end
  end

  describe "tanyao" do
    simple_tiles = "2s 2s 2s  4s 5s 6s  7s 7s 7s  2p 2p 2p"

    it "reports 1 when present" do
      ["3p 3p", "2m 2m"].each do |atama|
        hand = Hand.new(simple_tiles + " " + atama)
        arrangement = hand.complete_arrangements.first
        hand.tanyao(arrangement).must_equal(1, "#{hand} is tanyao")

        # Same hand with 4 open melds
        melds = arrangement.take(4)
        open_hand = Hand.new(atama, melds: melds)
        open_hand.tanyao(arrangement.drop(4)).must_equal(1, "#{open_hand} is tanyao")
      end
    end

    it "reports 0 when not present" do
      ["Ww Ww", "1s 1s"].each do |atama|
        hand = Hand.new(simple_tiles + " " + atama)
        arrangement = hand.complete_arrangements.first
        hand.tanyao(arrangement).must_equal(0, "#{hand} is not tanyao")
      end
    end

  end

  describe "yakuhai" do
    other_tiles = "2s 2s 2s  4s 5s 6s  9s 9s"

    it "reports 1 for each value tile pung" do
      [
        ["Gd Gd Gd  1p 1p 1p", :east, :east,    1],
        ["Ew Ew Ew  1p 1p 1p", :south, :west,   0],
        ["Ew Ew Ew  1p 1p 1p", :east, :west,    1],
        ["Ew Ew Ew  1p 1p 1p", :east, :east,    2],
        ["Ew Ew Ew  Rd Rd Rd", :east, :east,    3],
      ].each do |tiles, bakaze, jikaze, score|
        hand = Hand.new(other_tiles + " " + tiles, bakaze: bakaze, jikaze: jikaze)
        arrangement = hand.complete_arrangements.first
        hand.yakuhai(arrangement).must_equal(score, "#{hand} should score #{score}")
      end
    end
  end

end