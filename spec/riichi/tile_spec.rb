require 'spec_helper'

describe Tile do

  to_tile = lambda { |str| Tile.from_s(str) }

  describe "from_s" do
    it "works for a wind" do
      t = Tile.from_s('W')
      t.suit.must_be_nil
      t.rank.must_be_nil
      t.str.must_equal 'W'
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

  describe "pung?" do
    it "is true with three matching tiles" do
      [%w[5s 5s 5s], %w[F F F]].each do |strings|
        set = strings.map(&to_tile)
        Tile.pung?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [%w[5s 5s 6s], %w[1m 2m 3m], %w[2p F F]].each do |strings|
        set = strings.map(&to_tile)
        Tile.pung?(set).must_equal false
      end
    end
  end

  describe "chow?" do
    it "is true with suited tiles in ascending order" do
      [%w[1s 2s 3s], %w[5p 6p 7p]].each do |strings|
        set = strings.map(&to_tile)
        Tile.chow?(set).must_equal true
      end
    end

    it "is false otherwise" do
      [
        %w[5s 7s 6s],
        %w[7s 6s 5s],
        %w[2m 2m 3m],
        %w[F F F]
      ].each do |strings|
        set = strings.map(&to_tile)
        Tile.chow?(set).must_equal false
      end
    end
  end

  describe "Comparable" do
    it "should sort properly" do
      unsorted = '1m 2p 3s 2s 3m 2m 1s 1m B B F N E W S'
      sorted   = '2p 1s 2s 3s 1m 1m 2m 3m E S W N B B F'

      unsorted.split(' ').map(&to_tile).sort.join(' ').must_equal sorted
    end
  end
end