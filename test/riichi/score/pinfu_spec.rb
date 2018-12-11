require 'spec_helper'

describe Riichi::Score::Pinfu do
  context "open hand with all chows" do
    it "scores 0" do
      yaku_count("s123 p123 m678 s77", melds: "m123").must_equal(0)
    end
  end

  context "closed hand with one pung" do
    it "scores 0" do
      yaku_count("s123 p123 m678 m555 s77").must_equal(0)
    end
  end

  context "closed hand with one pung" do
    it "scores 0" do
      yaku_count("s123 p123 m678 m555 s77").must_equal(0)
    end
  end

  context "middle wait" do
    it "scores 0" do
      hand = Riichi::Hand.new("p57 -- s123 p123 m678 s77")
      hand.draw!(Riichi::Tile.to_tile("6p"))
      yaku_count(hand).must_equal(0)
    end
  end

  context "one sided end wait" do
    it "scores 0" do
      hand = Riichi::Hand.new("p89 -- s123 p123 m678 s77")
      hand.draw!(Riichi::Tile.to_tile("7p"))
      yaku_count(hand).must_equal(0)

      hand = Riichi::Hand.new("p12 -- s123 p123 m678 s77")
      hand.draw!(Riichi::Tile.to_tile("3p"))
      yaku_count(hand).must_equal(0)
    end
  end

  context "all conditions satisfied" do
    it "scores 1" do
      hand = Riichi::Hand.new("p78 -- s123 p123 m678 s77")
      hand.draw!(Riichi::Tile.to_tile("9p"))
      yaku_count(hand).must_equal(1)
    end
  end
end
