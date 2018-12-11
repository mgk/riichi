require 'spec_helper'

describe Riichi::Count::Ittsu do
  context "straight not complete in one suit" do
    it "scoreds 0" do
      yaku_count("p123456 m789 GGG s77").must_equal(0)
    end
  end

  context "all ranks present, but not required chows" do
    it "scores 0" do
      yaku_count("p123-345-678-789 m77").must_equal(0)
    end
  end

  context "closed" do
    it "scores 2" do
      yaku_count("p123456789 GGG m77").must_equal(2)
    end
  end

  context "open" do
    it "scores 1" do
      yaku_count("p123456789 m77", melds: "GGG").must_equal(1)
    end
  end

end

