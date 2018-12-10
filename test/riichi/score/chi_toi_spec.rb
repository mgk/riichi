require 'spec_helper'

describe Riichi::Score::ChiToi do
  context "hand with chows and pung" do
    it "scores 0" do
      yaku_count("s123 m123 p123 m333 s77").must_equal(0)
    end
  end

  context "7 pairs" do
    it "scores 2" do
      yaku_count("m11 m33 s11 s33 p11 p22 p88").must_equal(2)
    end
  end
end
