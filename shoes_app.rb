require 'shoes'
require 'riichi'

tiles = Riichi::Tile.deck.sample(13).map(&:to_s)

# use shoes4 to run
# https://github.com/shoes/shoes4

Shoes.app :title => "Riichi", :width => 800 do
  stack :margin => 50 do
    banner "Riichi"
    flow do
      tiles.each do |tile|
        flow :width => 60 do
          border blue
          image "images/#{tile}.png", :width => 50, :left => 5
        end
      end
    end
  end
end
