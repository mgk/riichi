require 'spec_helper'

describe "Tile" do
  it "to_s" do
    Tile.new(suit: :pinzu, rank: 4).to_s.must_equal('4p')
  end

  it "from_s" do
    Tile.from_s('W').must_equal(Tile.new(dragon: :white))
    Tile.from_s('7s').must_equal(Tile.new(suit: :sozu, rank: 7))
  end
end
