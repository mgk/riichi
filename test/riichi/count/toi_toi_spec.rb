require 'spec_helper'

describe Riichi::Count::ToiToi do
  context "one chow and 3 pungs" do
    it "scores 0" do
      yaku_count("s123 m111 p222 m333 s77").must_equal(0)
    end
  end

  context "closed hand all pungs" do
    it "scores 2" do
      yaku_count("s111-222 m111-333 s77").must_equal(2)
    end
  end

  context "closed hand all pungs and kongs" do
    it "scores 2" do
      yaku_count("s111 s222 s77", kongs: ['p1111', 'RRRR']).must_equal(2)
    end
  end

  context "open hand all pungs" do
    it "scores 2" do
      yaku_count("s222-444-777 m22", melds: "p222").must_equal(2)
      yaku_count("m22", melds: ["s222", "s444", "s777", "nnn"]).must_equal(2)
    end
  end
end
