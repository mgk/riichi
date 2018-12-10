describe Riichi::Score::Chanta do
  context "not all sets include outside tile" do
    it "scores 0" do
      yaku_count("p123 p456 m789 GGG - m99").must_equal(0)
    end
  end

  context "atama is simple" do
    it "scores 0" do
      yaku_count("p123 p123 s999 m111 - m77").must_equal(0)
    end
  end

  context "no honours tiles (junchan)" do
    it "scores 0" do
      yaku_count("p123 p999 s123 s111 m99").must_equal(0)
    end
  end

  context "all outside tiles (honroto)" do
    it "scores 0" do
      yaku_count("p111 p999 nnn s111 RR").must_equal(0)
    end
  end

  context "closed" do
    it "scores 2" do
      yaku_count("p123 p123 p789 GGG nn").must_equal(2)
    end
  end

  context "open" do
    it "scores 1" do
      yaku_count("p123-123-789 m11", melds: "GGG").must_equal(1)
    end
  end
end
