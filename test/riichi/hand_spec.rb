require 'spec_helper'

describe Hand do

  def t(s); Tile.to_tiles(s); end

  describe "complete?" do
    it "returns false for incomplete hands" do
      [
        "",
        "1s",
        "1s 1s 1s",
        "1s 2s",
        "1s 1s 1s Wd Gd"
      ]
      .each do |tiles|
        Hand.new(tiles).complete?.must_equal(false, "'#{tiles}' is not complete")
      end
    end
    it "returns true for complete hands" do
      [
        "1s 1s",
        "1s 1s 1s Wd Wd",
        "1s 2s 3s 4s 5s 6s 7s 7s 7s Ww Ww",
      ]
      .each do |tiles|
        Hand.new(tiles).complete?.must_equal(true, "'#{tiles}' is complete")
      end
    end
  end

  describe "waiting_tiles" do
    it "reports tiles that complete the hand with given arrangement" do
      [
        ["1s 1s 1s Wd",          ["1s 1s 1s"], "Wd"],
        ["1s 1s 1s 3m 2m Nw Nw", ["1s 1s 1s"], "1m 4m"],
        ["1s 1s 1s 3m 2m Nw Nw", ["1s 1s 1s"], "1m 4m"],
      ].map do |hand, arrangement, waiting_tiles|
        [Hand.new(hand),
          arrangement.map { |s| Tile.to_tiles(s) },
          Tile.to_tiles(waiting_tiles)]
      end.each do |hand, arrangement, waiting_tiles|
        hand.waiting_tiles(arrangement).must_equal(waiting_tiles, hand)
      end
    end
  end

  describe "waits" do
    it "reports winning tiles for tenpai hands" do
      [
        ["1s 1s 1s--2p 2p 2p--Wd Wd Wd--Ew Ew Ew-- Sw",
          [
            [["1s 1s 1s", "2p 2p 2p", "Wd Wd Wd", "Ew Ew Ew"], "Sw"]
          ]
        ],
      ].map do |hand, waits|
        hand = Hand.new(hand)
        waits = waits.map do |arrangement, waiting_tiles|
          [arrangement.map { |s| Tile.to_tiles(s) }.sort, Tile.to_tiles(waiting_tiles)]
        end
        [hand, waits]
      end.each do |hand, waits|
        hand.waits.must_equal(waits, hand)
      end
    end
  end

  describe "tanyao" do
    simple_tiles = "2s 2s 2s  4s 5s 6s  7s 7s 7s  2p 2p 2p"

    it "reports 1 when present" do
      ["3p 3p", "2m 2m"].each do |atama|
        hand = Hand.new(simple_tiles + " " + atama)
        arrangement = hand.complete_arrangements.first
        hand.tanyao(arrangement).must_equal(1, "#{hand} is tanyao")

        # Same hand with 4 open melds
        melds = arrangement.take(4)
        open_hand = Hand.new(atama, melds: melds)
        open_hand.tanyao(arrangement.drop(4)).must_equal(1, "#{open_hand} is tanyao")
      end
    end

    it "reports 0 when not present" do
      ["Ww Ww", "1s 1s"].each do |atama|
        hand = Hand.new(simple_tiles + " " + atama)
        arrangement = hand.complete_arrangements.first
        hand.tanyao(arrangement).must_equal(0, "#{hand} is not tanyao")
      end
    end

  end

  describe "yakuhai" do
    other_tiles = "2s 2s 2s  4s 5s 6s  9s 9s"

    it "reports 1 for each value tile pung" do
      [
        ["Gd Gd Gd  1p 1p 1p", :east, :east,    1],
        ["Ew Ew Ew  1p 1p 1p", :south, :west,   0],
        ["Ew Ew Ew  1p 1p 1p", :east, :west,    1],
        ["Ew Ew Ew  1p 1p 1p", :east, :east,    2],
        ["Ew Ew Ew  Rd Rd Rd", :east, :east,    3],
      ].each do |tiles, bakaze, jikaze, score|
        hand = Hand.new(other_tiles + " " + tiles, bakaze: bakaze, jikaze: jikaze)
        arrangement = hand.complete_arrangements.first
        hand.yakuhai(arrangement).must_equal(score, "#{hand} should score #{score}")
      end
    end
  end

  describe "pinfu" do
    it "reports 0 for an open hand" do
      hand = Hand.new('1s 2s 3s - 1p 2p 3p - 6m 7m 8m -- 7s 7s',
                      melds: [Tile.to_tiles('1m 2m 3m')])
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.pinfu(arrangement).must_equal(0, hand)
    end

    it "reports 0 for a hand with pungs" do
      chows = '2p 3p 4p - 2p 3p 4p - 2m 3m 4m'
      atama = '6s 6s'

      ['1s 1s 1s', 'Ew Ew Ew', 'Gd Gd Gd', '7m 7m 7m'].each do |pung|
        hand = Hand.new([chows, pung, atama].join(' '))
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.pinfu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 for a middle wait" do
      hand = Hand.new('--5p 7p-- 1s 2s 3s - 1p 2p 3p - 6m 7m 8m - 7s 7s')
      hand.draw(Tile.to_tile('6p'))
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.pinfu(arrangement).must_equal(0, hand)
    end

    it "reports 0 for a one sided end waits" do
      [['8p 9p', '7p'], ['1p 2p', '3p']].each do |tatsu, winning_tile|
        hand = Hand.new("#{tatsu} 1s 2s 3s - 1m 2m 3m - 6m 7m 8m - 7s 7s")
        hand.draw(Tile.to_tile(winning_tile))
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.pinfu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 1 for pinfu" do
      hand = Hand.new('--5p 6p-- 1s 2s 3s - 1p 2p 3p - 6m 7m 8m - 7s 7s')
      hand.draw(Tile.to_tile('4p'))
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.pinfu(arrangement).must_equal(1, hand)
    end
  end

  describe "toitoi" do
    it "reports 0 when not all pungs" do
      hand = Hand.new('1s 2s 3s - 1m 1m 1m - 2m 2m 2m - 3m 3m 3m -7s 7s')
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.toitoi(arrangement).must_equal(0, hand)
    end

    it "reports 2 when all pungs for closed hand" do
      hand = Hand.new('1s 1s 1s - 1m 1m 1m - 2m 2m 2m - 3m 3m 3m -7s 7s')
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.toitoi(arrangement).must_equal(2, hand)
    end

    it "reports 2 when all pungs for open hand" do
      hand = Hand.new('1s 1s 1s - 1m 1m 1m - 2m 2m 2m - 7s 7s',
        melds: [Tile.to_tiles('Ww Ww Ww')])
      hand.open?.must_equal(true)
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.toitoi(arrangement).must_equal(2, hand)
    end
  end

  describe "san shoku dojun - three color same sequence" do
    it "reports 0 when not present" do
      ['1s 2s 3s - 1m 2m 3m - 2p 3p 4p - 3m 3m 3m -7s 7s',
        '1s 2s 3s - 1m 2m 3m - 1m 2m 3m - 5m 5m 5m -7s 7s'].each do |hand|
        hand = Hand.new(hand)
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.mixed_triple_chow(arrangement).must_equal(0, hand)
      end
    end

    it "reports 2 for closed hands" do
      ['1s 2s 3s - 1m 2m 3m - 1p 2p 3p - 3m 3m 3m -7s 7s',
        '4s 5s 6s - 4m 5m 6m - 4p 5p 6p - Rd Rd Rd - Ew Ew'].each do |hand|
        hand = Hand.new(hand)
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.mixed_triple_chow(arrangement).must_equal(2, hand)
      end
    end

    it "reports 1 for open hands" do
      [
        ['1s 2s 3s - 1m 2m 3m - 1p 2p 3p', '7s 7s 7s'],
        ['4s 5s 6s - 4m 5m 6m - Rd Rd Rd', '4p 5p 6p'],
      ].each do |tiles, meld|
        hand = Hand.new(tiles + ' Sw Sw', melds: [Tile.to_tiles(meld)])
        arrangement = hand.complete_arrangements.first
        arrangement.empty?.must_equal(false)
        hand.mixed_triple_chow(arrangement).must_equal(1, hand)
      end
    end
  end

end