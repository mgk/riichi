require 'spec_helper'

describe Riichi::Score do
  context "tsumo!" do
    context "closed" do
      context "pinfu iipeiko" do
        it "scores 2 yaku, 20 fu" do
          hand = Riichi::Hand.new('p123123 m234 s56 - s33')
          hand.draw! '4s'
          hand.tsumo!
          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({pinfu: 1, iipeko: 1})
          score.total_yaku.must_equal(2)
          score.fu.must_equal(20)
        end
      end
    end
    context "open" do
      context "honitsu and dragon pung" do
        it "scores 2 yaku, 40 fu" do
          hand = Riichi::Hand.new('m123 m555 ww RR', melds: "m777")
          hand.draw! 'R'
          hand.tsumo!
          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({honitsu: 2, chun: 1})
          score.total_yaku.must_equal(3)
          score.fu.must_equal(40)
        end
      end
      context "several sets" do
        it "scores 60 fu" do
          hand = Riichi::Hand.new('p111 s24 GG',
            melds: "eee", kongs: 'm4444')
          hand.draw! 's3'
          hand.tsumo!
          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({ton: 2})
          score.total_yaku.must_equal(2)
          score.fu.must_equal(60)
        end
      end
    end
  end

  context "ron!" do
    context "closed" do
      context "pinfu iipeiko" do
        it "scores 2 yaku, 30 fu" do
          hand = Riichi::Hand.new('p123123 m234 s56 - s33')
          hand.ron! '4s'

          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({pinfu: 1, iipeko: 1})
          score.total_yaku.must_equal(2)
          score.fu.must_equal(30)
        end
      end
      context "Saki anime, episode 18" do
        it "scores 110 fu" do
          hand = Riichi::Hand.new('s678 ss m11',
            bakaze: :nan,
            jikaze: :nan,
            kongs: ['GGGG', 'p1111'])

          hand.ron! 'm1'

          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({hatsu: 1})
          score.total_yaku.must_equal(1)
          score.fu.must_equal(110)
        end
      end
      context "open pinfu and san ski" do
        it "scores 1 yaku, 30 fu" do
          hand = Riichi::Hand.new('s789 p789 m33 s23', melds: 'm789')
          hand.ron! '1s'

          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({sanshoku: 1})
          score.total_yaku.must_equal(1)
          score.fu.must_equal(30)
        end
      end
      context "tanyao" do
        it "scores 1 yaku, 40 fu" do
          hand = Riichi::Hand.new('m222-456 p22-56 s567')
          hand.ron! 'p7'

          score = Riichi::Score.best_score(hand)

          score.yaku.must_equal({tanyao: 1})
          score.total_yaku.must_equal(1)
          score.fu.must_equal(40)
        end
      end
    end
  end
end
