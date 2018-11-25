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
    simple_tiles = "2s 2s 2s 4s 5s 6s 7s 7s 7s 2p 2p 2p"

    it "reports 1 when present" do
      ["3p 3p", "2s 2s"].each do |atama|
        hand = Hand.new(simple_tiles + " " + atama)
        arrangement = hand.complete_arrangements.first
        hand.tanyao(arrangement).must_equal(1, "#{hand} is tanyao")
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
end