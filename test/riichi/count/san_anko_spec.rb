require 'spec_helper'

describe Riichi::Count::SanAnko do
  context "only 2 pungs" do
    it "scores 0" do
      yaku_count("m111 m222 m345 m567 - nn").must_equal(0)
    end
  end

  context "4 concealed pungs (su anko!)" do
    it "scores 0" do
      yaku_count("m111 m222 m555 eee - nn").must_equal(0)
    end
  end

  context "2 closed pungs and 1 open" do
    it "scores 0" do
      yaku_count("m111 m222 m345 - nn", melds: "RRR").must_equal(0)
    end
  end

  context "3 concealed pungs and one open chow" do
    it "scores 2" do
      yaku_count("m111 m222 m444 - nn", melds: "s123").must_equal(2)
    end
  end

  context "3 concealed pungs and 1 open pung" do
    it "scores 0" do
      yaku_count("m111 m222 s444 - nn", melds: "GGG").must_equal(2)
    end
  end

  context "2 concealed pungs, ron on third pung" do
    it "scores 2" do
      # waiting on m4
      hand = Riichi::Hand.new("s123 m111 m222 m44 nn")

      # ron! m4
      hand.ron!('m4')

      # not san anko :(
      hand_counter(hand).yaku_count.must_equal(0)
    end
  end

  context "2 concealed pungs, tsumo on third pung" do
    it "scores 2" do
      # waiting on m4
      hand = Riichi::Hand.new("s123 m111 m222 m44 nn")

      # tsumo! m4
      hand.tsumo!('m4')

      # not san anko :(
      hand_counter(hand).yaku_count.must_equal(2)
    end
  end
end
