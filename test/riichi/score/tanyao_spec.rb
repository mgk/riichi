require 'spec_helper'

describe Riichi::Score::Tanyao do
  context "closed hand all simples" do
    it "scores 1" do
      yaku_count("s222-456-777 p222 m22").must_equal(1)
    end
  end

  context "open hand all simples" do
    it "scores 1" do
      yaku_count("s222-456-777 m22", melds: "p222").must_equal(1)
    end
  end

  context "closed hand with a terminal" do
    it "scores 0" do
      yaku_count("s222-456-777 m123 m88").must_equal(0)
    end
  end

  context "closed hand with honours" do
    it "scores 0" do
      yaku_count("s222-456-777 nnn m88").must_equal(0)
    end
  end
end