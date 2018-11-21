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

  def deal_tile
    tile = @deck.shift
    @hand << tile
    tile
  end
end

TILE_WIDTH = 60

Shoes.app :title => "Riichi", :width => 1000, :height => 600 do

  def refresh_hand
    @hand.clear do
      layout_tiles(@g.hand)
    end
    refresh
  end

  def refresh
    @remaining.text = "remaining: #{@g.deck.size}"

    @draw_button.state = @g.hand.size % 3 == 1 ? 'enabled' : 'disabled'
    if @selected && @draw_button.state == 'disabled'
      @discard_button.state = 'enabled'
    else
      @discard_button.state = 'disabled'
    end
  end

  def layout_tiles(tiles, selectable: true)
    @tiles = tiles.each_with_index.map do |tile_name, idx|
      tile = layout_tile(tile_name, TILE_WIDTH, idx * TILE_WIDTH)
      if selectable
        tile.click do
          toggle_selected(idx)
        end
      end
      tile
    end
  end

  def draw
    left = TILE_WIDTH * @g.hand.size + TILE_WIDTH / 2
    tile = layout_tile(@g.deal_tile, TILE_WIDTH, left)
    @tiles << tile
    tile.click do
      toggle_selected(@g.hand.size - 1)
    end
    refresh
  end

  def discard
    info "discard [#{@selected}] - #{@g.hand[@selected]}"
    @g.hand.delete_at @selected
    clear_selection
    @g.hand.sort!
    refresh_hand
  end

  def layout_tile(tile_name, width, left)
    stack(:width => width, :left => left, :margin => 5) do
      border black
      image("images/#{tile_name}.png", :width => width - 10)
    end
  end

  def deal
    @g.deal_hand
  end

  def toggle_selected(idx)
    if @selected == idx
      clear_selection
    else
      select(idx)
    end
    refresh
  end

  def select(idx)
    clear_selection
    @tiles[idx].top -= 30
    @selected = idx
  end

  def clear_selection
    if @selected
      @tiles[@selected].top = 0
      @selected = nil
    end
  end

  def new_game
    @g = Game.new self
    deal
  end

  new_game

  stack :margin => 10 do
    banner "Riichi"
    @remaining = caption "remaining: #{@g.deck.size}"

    stack do
      @hand = flow :margin_top => 40, :margin_bottom => 40
    end

    flow do
      button "Deal" do
        @hand.clear do
          deal
        end
      end
      @draw_button = button "Draw" do
        @hand.append do
          draw
        end
      end
      @discard_button = button "Discard" do
        discard
      end
      button "Restart" do
        @hand.clear
        new_game
        @remaining.text = "remaining: #{@g.deck.size}"
      end
    end
  end

  refresh_hand
end
