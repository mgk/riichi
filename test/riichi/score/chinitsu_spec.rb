require 'spec_helper'

describe Riichi::Score::Chinitsu do
  context "more than one suit" do
    it "scores 0" do
      yaku_count("p123-456 m111-789 - p99").must_equal(0)
    end
  end

  context "has honours" do
    it "scores 0" do
      yaku_count("p123456789 RRR - p99").must_equal(0)
    end
  end

  context "open" do
    it "scores 5" do
      yaku_count("p123-789-444-22", melds: "p123").must_equal(5)
    end
  end

  context "closed" do
    it "scores 6" do
      yaku_count("m111-222-444-789-66").must_equal(6)
    end
  end
end
