require 'shoes'
require 'riichi'

# use shoes4 to run
# https://github.com/shoes/shoes4

# todo: separate window for combos

class Game
  attr_accessor :selected, :hand, :deck

  def initialize(app)
    @app = app
    @deck = Riichi::Tile.deck.shuffle
  end

  def deal_hand
    @hand = @deck.shift(13).sort
    @app.info hand
  end

end

Shoes.app :title => "Riichi", :width => 1000, :height => 600 do

  def layout_tiles(tiles)
    tiles.each_with_index do |tile_name, idx|
      tile = stack(:width => 60, :left => idx * 60, :margin => 5) do
        border black
        image("images/#{tile_name}.png", :width => 50)
      end
      tile.click do
        toggle_selected(tile)
      end
    end
  end

  def deal
    @g.deal_hand
    layout_tiles(@g.hand)
    @remaining.text = "remaining: #{@g.deck.size}"
  end

  def toggle_selected(tile_image)
    if @selected == tile_image
      clear_selection
    else
      select(tile_image)
    end
  end

  def select(tile_image)
    clear_selection
    info "height: #{tile_image.dimensions.height}, width: #{tile_image.dimensions.width}"
    tile_image.top -= 30
    @selected = tile_image
  end

  def clear_selection
    if @selected
      @selected.top = 0
      @selected = nil
    end
  end

  def new_game
    @g = Game.new self
  end

  new_game

  stack :margin => 10 do
    banner "Riichi"
    @remaining = para "remaining: #{@g.deck.size}"
    stack do
      border blue, strokewidth: 3
      @hand = flow :margin_top => 40, :margin_bottom => 40 do
        deal
      end
    end
    flow do
      button("Deal") do
        @hand.clear do
          deal
        end
      end
      button("Restart") do
        @hand.clear
        new_game
        @remaining.text = "remaining: #{@g.deck.size}"
      end
    end
  end
end
