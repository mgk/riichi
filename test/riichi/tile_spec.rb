require 'spec_helper'

describe Tile do

  to_tile = lambda { |str| Tile.from_s(str) }

  describe "from_s" do
    it "works for a wind" do
      t = Tile.from_s('Ww')
      t.suit.must_be_nil
      t.rank.must_be_nil
      t.str.must_equal 'Ww'
      t.wind.must_equal :west
      t.dragon.must_be_nil
    end

    it "works for a suited tile" do
      t = Tile.from_s('1p')
      t.suit.must_equal :pinzu
      t.rank.must_equal 1
      t.str.must_equal '1p'
      t.wind.must_be_nil
      t.dragon.must_be_nil
    end

  end

  describe "Comparable" do
    it "should sort properly" do
      unsorted = '1m 2p 3s 2s 3m 2m 1s 1m Wd Wd Gd Nw Ew Ww Sw'
      sorted   = '2p 1s 2s 3s 1m 1m 2m 3m Ew Sw Ww Nw Wd Wd Gd'

      unsorted.split(' ').map(&to_tile).sort.join(' ').must_equal sorted
    end
  end
end