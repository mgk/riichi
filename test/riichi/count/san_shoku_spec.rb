require 'spec_helper'

describe Riichi::Count::SanShoku do
  context "two suits" do
    it "scores 0" do
      yaku_count("m123 m123 s123 RRR m55").must_equal(0)
    end
  end

  context "open 3 suits" do
    it "scores 1" do
      yaku_count("m123 s123 p123 m55", melds: "GGG").must_equal(1)
    end
  end

  context "closed 3 suits" do
    it "scores 2" do
      yaku_count("m123 s123 p123 sss m55").must_equal(2)
    end
  end
end
