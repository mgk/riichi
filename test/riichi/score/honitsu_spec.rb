require 'spec_helper'

describe Riichi::Score::Honitsu do
  context "more than one suit" do
    context "closed" do
      it "scores 0" do
        yaku_count("p111 p123 GGG p999 - m77").must_equal(0)
      end
    end
    context "open" do
      it "scores 0" do
        yaku_count("p111 p123 p999 - m77", melds: "GGG").must_equal(0)
      end
    end
  end

  context "full flush (chinitsu!)" do
    it "scores 0" do
      yaku_count("m123456789-999-11").must_equal(0)
    end
  end

  context "no suits (tsuiiso!)" do
    it "scores 0" do
      yaku_count("eee sss www RRR GG").must_equal(0)
    end
  end

  context "open" do
    context "one suit, all pungs" do
      it "scores 2" do
        yaku_count("p111-333-555 nn", melds: "p777").must_equal(2)
      end
    end
  end

  context "closed" do
    context "one suit and honours" do
      it "scores 3" do
        yaku_count("p111-123-999 GGG nn").must_equal(3)
      end
    end

    context "one suit, all chows" do
      it "scores 3" do
        yaku_count("p123456789-789 nn").must_equal(3)
      end
    end

    context "one suit, all pungs" do
      it "scores 3" do
        yaku_count("p111-333-555-777 nn").must_equal(3)
      end
    end
  end

end
