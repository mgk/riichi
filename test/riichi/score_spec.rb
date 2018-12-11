require 'spec_helper'

describe Riichi::Score do
  context "pinfu iipeiko" do
    hand = Riichi::Hand.new('p123123 m234 s56 - s33')
    hand.draw! '4s'

    it "scores 2" do
      score = Riichi::Score.best_score(hand)

      score.total_yaku.must_equal(2, score.inspect)
      score.yaku.must_equal({pinfu: 1, iipeko: 1}, score.inspect)
    end
  end

  context "open honitsu and dragon pung" do
    hand = Riichi::Hand.new('m123-555-777-ww', melds: "RRR")

    it "scores 2" do
      score = Riichi::Score.best_score(hand)

      score.total_yaku.must_equal(3, score.inspect)
      score.yaku.must_equal({honitsu: 2, chun: 1}, score.inspect)
    end
  end
end