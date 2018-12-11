require 'spec_helper'

describe Riichi::Count::Iipeko do
  context "not same suit" do
    it "scores 0" do
      yaku_count("m123 p123 s123 RRR m55").must_equal(0)
    end
  end

  context "open" do
    it "scores 0" do
      yaku_count("m123 s123 p123 m55", melds: "GGG").must_equal(0)
    end
  end

  context "closed" do
    it "scores 1" do
      yaku_count("m123 m123 www sss m55").must_equal(1)
    end
  end
end
