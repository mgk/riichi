require 'spec_helper'

describe Hand do

  def t(s); Tile.to_tiles(s); end

  describe "complete?" do
    it "returns false for incomplete hands" do
      [
        ["1s", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p", "4p 4p 4p"]],
        ["1s 1s 1s 1s", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p"]],
        ["1s 2s", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p", "Gd Gd Gd"]],
        ["1s 1s 1s Wd", ["1p 1p 1p", "2p 2p 2p", "3p 3p 3p"]],
        ["4p 4p - 1p 1p - 2p 2p - Ew Ew - Sw Sw - Ww Ww - Gd", [""]],
      ]
      .each do |tiles, melds|
        Hand.new(tiles, melds: melds.map { |m| Tile.to_tiles(m) })
          .complete?.must_equal(false, "'#{tiles}' is not complete")
      end
    end
    it "returns true for complete hands" do
      [
        "1s 1s",
        "1s 1s 1s Wd Wd",
        "1s 2s 3s 4s 5s 6s 7s 7s 7s Ww Ww",
        "4p 4p - 1p 1p - 2p 2p - Ew Ew - Sw Sw - Ww Ww - Nw Nw",
      ]
      .each do |tiles|
        tiles = Tile.to_tiles(tiles)
        num_melds = (14 - tiles.length) / 3
        melds = (1..num_melds).map do |num|
          [Tile.get(suit: :pinzu, rank: num)] * 3
        end
        Hand.new(tiles, melds: melds)
          .complete?.must_equal(true, "'#{tiles}' is complete")
      end
    end
  end

  describe "waiting_tiles" do
    it "reports tiles that complete the hand with given arrangement" do
      [
        ["1s 1s 1s Wd",          ["1s 1s 1s"], "Wd"],
        ["1s 1s 1s 3m 2m Nw Nw", ["1s 1s 1s"], "1m 4m"],
        ["1s 1s 1s 3m 2m Nw Nw", ["1s 1s 1s"], "1m 4m"],
      ].map do |tiles, arrangement, waiting_tiles|
        tiles = Tile.to_tiles(tiles)
        num_melds = (13 - tiles.length) / 3
        melds = (1..num_melds).map do |num|
          [Tile.get(suit: :pinzu, rank: num)] * 3
        end
        [Hand.new(tiles, melds: melds),
          arrangement.map { |s| Tile.to_tiles(s) },
          Tile.to_tiles(waiting_tiles)]
      end.each do |hand, arrangement, waiting_tiles|
        hand.waiting_tiles(arrangement).must_equal(waiting_tiles, hand)
      end
    end
  end

  describe "waits" do
    it "reports list of winning tiles for tenpai hands" do
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

  describe "complete?" do
    it "reports true for complete hands" do
      [
        '1s 1s 1s - 2p 2p 2p - 3m 3m 3m - Gd Gd Gd - Rd Rd',
        '1s 1s - 2p 2p - 3s 3s - 4m 4m - 5s 5s - 6p 6p - 7s 7s',
      ].each do |tiles|
        hand = Hand.new(tiles)
        hand.complete?.must_equal(true, tiles)
        hand.complete_arrangements.length.must_equal(1)
      end
    end

    it "reports false for incomplete hands" do
      [
        '1s 1s - 2p 2p - 3s 3s - 4m 4m - 5s 5s -- 6s 6s 6s 6s',
      ].each do |tiles|
        Hand.new(tiles).complete?.must_equal(false, tiles)
      end
    end
  end

  describe "tanyao" do
    simple_tiles = "2s 2s 2s  4s 5s 6s  7s 7s 7s  2p 2p 2p"

    it "reports 1 when present" do
      ["3p 3p", "2m 2m"].each do |atama|
        hand = Hand.new(simple_tiles + " " + atama)
        hand.complete_arrangements.length.must_equal(1)
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
        hand.complete_arrangements.length.must_equal(1)
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
        hand.complete_arrangements.length.must_equal(1)
        arrangement = hand.complete_arrangements.first
        hand.yakuhai(arrangement).must_equal(score, "#{hand} should score #{score}")
      end
    end
  end

  describe "pinfu" do
    it "reports 0 for an open hand" do
      hand = Hand.new('1s 2s 3s - 1p 2p 3p - 6m 7m 8m -- 7s 7s',
                      melds: [Tile.to_tiles('1m 2m 3m')])
      hand.complete_arrangements.length.must_equal(1)
      arrangement = hand.complete_arrangements.first
      arrangement.empty?.must_equal(false)
      hand.pinfu(arrangement).must_equal(0, hand)
    end

    it "reports 0 for a hand with pungs" do
      chows = '2p 3p 4p - 2p 3p 4p - 2m 3m 4m'
      atama = '6s 6s'

      ['1s 1s 1s', 'Ew Ew Ew', 'Gd Gd Gd', '7m 7m 7m'].each do |pung|
        hand = Hand.new([chows, pung, atama].join(' '))
        hand.complete_arrangements.length.must_equal(1)
        arrangement = hand.complete_arrangements.first
        hand.pinfu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 for a middle wait" do
      hand = Hand.new('--5p 7p-- 1s 2s 3s - 1p 2p 3p - 6m 7m 8m - 7s 7s')
      hand.draw(Tile.to_tile('6p'))
      hand.complete_arrangements.length.must_equal(1)
      arrangement = hand.complete_arrangements.first
      hand.pinfu(arrangement).must_equal(0, hand)
    end

    it "reports 0 for a one sided end waits" do
      [['8p 9p', '7p'], ['1p 2p', '3p']].each do |tatsu, winning_tile|
        hand = Hand.new("#{tatsu} 1s 2s 3s - 1m 2m 3m - 6m 7m 8m - 7s 7s")
        hand.draw(Tile.to_tile(winning_tile))
        hand.complete_arrangements.length.must_equal(1)
        arrangement = hand.complete_arrangements.first
        hand.pinfu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 1 for pinfu" do
      hand = Hand.new('--5p 6p-- 1s 2s 3s - 1p 2p 3p - 6m 7m 8m - 7s 7s')
      hand.draw(Tile.to_tile('4p'))
      hand.complete_arrangements.length.must_equal(1)
      arrangement = hand.complete_arrangements.first
      hand.pinfu(arrangement).must_equal(1, hand)
    end
  end

  describe "honitsu" do
    it "reports 0 when closed with more than one suit" do
      hand = Hand.new("1p 1p 1p - 1p 2p 3p - Gd Gd Gd - 9p 9p 9p - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 when open with more than one suit" do
      hand = Hand.new("1p 2p 3p - Gd Gd Gd - 9p 9p 9p - 7m 7m",
        melds: [Tile.to_tiles("1m 1m 1m")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 for a full flush (chinitsu)" do
      hand = Hand.new("1m 2m 3m 4m 5m 6m 7m 8m 9m 9m 9m 9m 1m 1m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 when there are no suits (tsuiiso!)" do
      hand = Hand.new("Ew Ew Ew - Sw Sw Sw - Ww Ww Ww - Rd Rd Rd - Gd Gd")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 3 when closed with one suit and honors" do
      hand = Hand.new("1p 1p 1p - 1p 2p 3p - Gd Gd Gd - 9p 9p 9p - Nw Nw")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(3, hand)
      end
    end

    it "reports 3 when closed, one suit, all chows, and honors" do
      hand = Hand.new("1p 2p 3p - 1p 2p 3p - 1p 2p 3p - 1p 2p 3p - Nw Nw")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(3, hand)
      end
    end

    it "reports 2 when open with more than one suit" do
      hand = Hand.new("1p 2p 3p - Gd Gd Gd - 9p 9p 9p - 7p 7p",
        melds: [Tile.to_tiles("1p 1p 1p")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.honitsu(arrangement).must_equal(2, hand)
      end
    end

  end

  describe "toitoi" do
    it "reports 0 when not all pungs" do
      hand = Hand.new('1s 2s 3s - 1m 1m 1m - 2p 2p 2p - 3m 3m 3m -7s 7s')
      hand.complete_arrangements.length.must_equal(1)
      arrangement = hand.complete_arrangements.first
      hand.toitoi(arrangement).must_equal(0, hand)
    end

    it "reports 2 when all pungs for closed hand" do
      hand = Hand.new('1s 1s 1s - 1m 1m 1m - 2p 2p 2p - 3m 3m 3m -7s 7s')
      hand.complete_arrangements.length.must_equal(1)
      arrangement = hand.complete_arrangements.first
      hand.toitoi(arrangement).must_equal(2, hand)
    end

    it "reports 2 when all pungs for open hand" do
      hand = Hand.new('1s 1s 1s - 1m 1m 1m - 2m 2m 2m - 7s 7s',
        melds: [Tile.to_tiles('Ww Ww Ww')])
      hand.open?.must_equal(true)
      hand.complete_arrangements.length.must_equal(1)
      arrangement = hand.complete_arrangements.first
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

  describe "chii toitsu" do
    it "reports 0 when not present" do
      ['1s 2s 3s - 1m 2m 3m - 2p 3p 4p - 3m 3m 3m - 7s 7s'].each do |hand|
        hand = Hand.new(hand)
        hand.complete_arrangements.length.must_equal(1)
        arrangement = hand.complete_arrangements.first
        hand.chii_toitsu(arrangement).must_equal(0, hand)
      end
    end
    it "reports 2 when present" do
      ['1m 1m - 3m 3m - 1s 1s - 3s 3s - 1p 1p - 2p 2p - 8p 8p'].each do |hand|
        hand = Hand.new(hand)
        hand.complete_arrangements.length.must_equal(1)
        arrangement = hand.complete_arrangements.first
        hand.chii_toitsu(arrangement).must_equal(2, hand)
      end
    end
  end

  describe "ittsu" do
    it "reports 0 when straight in suit is not complete" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7m 8m 9m - Gd Gd Gd - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.itsu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 when not all chows are present" do
      hand = Hand.new("1p 2p 3p - 3p 4p 5p - 6p 7p 8p - 7p 8p 9p - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.itsu(arrangement).must_equal(0, hand)
      end
    end

    it "reports 2 when closed" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7p 8p 9p - Gd Gd Gd - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.itsu(arrangement).must_equal(2, hand)
      end
    end

    it "reports 1 when open" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7p 8p 9p - 7m 7m",
        melds: [Tile.to_tiles("Gd Gd Gd")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.itsu(arrangement).must_equal(1, hand)
      end
    end
  end

  describe "chanta" do
    it "reports 0 when not all sets include outside tile" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7m 8m 9m - Gd Gd Gd - 9m 9m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 when atama is not outside tiles" do
      hand = Hand.new("1p 2p 3p - 3p 4p 5p - 6p 7p 8p - 7p 8p 9p - 7m 7m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 when all no honours tiles (junchan)" do
      hand = Hand.new("1p 2p 3p - 9p 9p 9p - 1s 2s 3s - 1s 1s 1s - 9m 9m")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta(arrangement).must_equal(0, hand)
      end
    end

    it "reports 0 when all outside tiles (honroto)!" do
      hand = Hand.new("1p 1p 1p - 9p 9p 9p - Nw Nw Nw - 1s 1s 1s - Rd Rd")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta(arrangement).must_equal(0, hand)
      end
    end

    it "reports 2 when closed" do
      hand = Hand.new("1p 2p 3p 1p 2p 3p 7p 8p 9p - Gd Gd Gd - Nw Nw")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta(arrangement).must_equal(2, hand)
      end
    end

    it "reports 1 when open" do
      hand = Hand.new("1p 2p 3p 1p 2p 3p 7p 8p 9p - 1m 1m",
        melds: [Tile.to_tiles("Gd Gd Gd")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chanta(arrangement).must_equal(1, hand)
      end
    end
  end

  describe "chinitsu" do
    it "reports 0 when not pure flush" do
      hand = Hand.new("1p 2p 3p 4p 5p 6p 7p 8p 9p - 1p 1p 1p - Rd Rd")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chinitsu(arrangement).must_equal(0, hand)
      end
    end

    # TODO 9 gates
    it "reports 6 when closed" do
      hand = Hand.new("1p 2p 3p 1p 2p 3p 7p 8p 9p - 4p 4p 4p - 2p 2p")
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chinitsu(arrangement).must_equal(6, hand)
      end
    end

    it "reports 5 when open" do
      hand = Hand.new("1p 2p 3p 7p 8p 9p - 4p 4p 4p - 2p 2p",
        melds: [Tile.to_tiles("1p 2p 3p")])
      hand.complete?.must_equal(true)
      hand.complete_arrangements.each do |arrangement|
        hand.chinitsu(arrangement).must_equal(5, hand)
      end
    end
  end
end