require 'spec_helper'

describe "dragons" do
  describe Riichi::Score::Haku do
    context "closed hand with dragon pung" do
      it "scores 1" do
        yaku_count("m123456789-99- WWW").must_equal(1)
      end
    end
    context "open hand with dragon pung" do
      it "scores 1" do
        yaku_count("m123456789-99", melds: "WWW").must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- eee").must_equal(0)
      end
    end
  end

  describe Riichi::Score::Hatsu do
    context "closed hand with dragon pung" do
      it "scores 1" do
        yaku_count("m123456789-99- GGG").must_equal(1)
      end
    end
    context "open hand with dragon pung" do
      it "scores 1" do
        yaku_count("m123456789-99", melds: "GGG").must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- eee").must_equal(0)
      end
    end
  end

  describe Riichi::Score::Chun do
    context "closed hand with dragon pung" do
      it "scores 1" do
        yaku_count("m123456789-99- RRR").must_equal(1)
      end
    end
    context "open hand with dragon pung" do
      it "scores 1" do
        yaku_count("m123456789-99", melds: "RRR").must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- eee").must_equal(0)
      end
    end
  end
end

describe "winds" do
  describe Riichi::Score::Ton do
    context "closed hand double wind" do
      it "scores 2" do
        yaku_count("m123456789-99- eee", bakaze: :ton, jikaze: :ton).must_equal(2)
      end
    end
    context "open hand seat wind only" do
      it "scores 1" do
        yaku_count("m123456789-99- eee", bakaze: :sha, jikaze: :ton).must_equal(1)
      end
    end
    context "closed hand prevailing wind only" do
      it "scores 1" do
        yaku_count("m123456789-99- eee", bakaze: :ton, jikaze: :pei).must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- www").must_equal(0)
      end
    end
  end

  describe Riichi::Score::Nan do
    context "closed hand double wind" do
      it "scores 2" do
        yaku_count("m123456789-99- sss", bakaze: :nan, jikaze: :nan).must_equal(2)
      end
    end
    context "open hand seat wind only" do
      it "scores 1" do
        yaku_count("m123456789-99- sss", bakaze: :ton, jikaze: :nan).must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- www").must_equal(0)
      end
    end
  end

  describe Riichi::Score::Sha do
    context "closed hand double wind" do
      it "scores 2" do
        yaku_count("m123456789-99- www", bakaze: :sha, jikaze: :sha).must_equal(2)
      end
    end
    context "open hand seat wind only" do
      it "scores 1" do
        yaku_count("m123456789-99- www", bakaze: :ton, jikaze: :sha).must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- GGG").must_equal(0)
      end
    end
  end

  describe Riichi::Score::Pei do
    context "closed hand double wind" do
      it "scores 2" do
        yaku_count("m123456789-99- nnn", bakaze: :pei, jikaze: :pei).must_equal(2)
      end
    end
    context "open hand seat wind only" do
      it "scores 1" do
        yaku_count("m123456789-99- nnn", bakaze: :ton, jikaze: :pei).must_equal(1)
      end
    end
    context "not present" do
      it "scores 0" do
        yaku_count("m123456789-99- GGG").must_equal(0)
      end
    end
  end
end
