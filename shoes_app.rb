require 'shoes'
require 'riichi'
require 'set'

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
  end

  def deal_tile
    tile = @deck.shift
    @hand << tile
    tile
  end

  def arrangements
    @app.info @hand
    Riichi::Tiles.arrangements(@hand)
  end

  def leftovers(arrangement)
    Riichi::Tiles.diff(@hand, arrangement)
  end
end

TILE_WIDTH = 50

Shoes.app :title => "Riichi", :width => 1000, :height => 600 do

  def refresh_hand
    @hand.clear do
      layout_tiles(@g.hand)
    end
    refresh
    @arrangements.clear do
      @g.arrangements.each do |arrangement|
        flow :margin_top => 10 do
          loc = 0
          leftovers = @g.leftovers(arrangement)
          info leftovers
          arrangement.each do |set|
            set.each do |tile|
              layout_tile(tile, width: TILE_WIDTH, left: loc, margin: 1)
              loc += TILE_WIDTH
            end
            loc += TILE_WIDTH / 3
          end
        end
      end
    end
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
      tile = layout_tile(tile_name, width: TILE_WIDTH, left: idx * TILE_WIDTH)
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
    tile = layout_tile(@g.deal_tile, width: TILE_WIDTH, left: left)
    @tiles << tile
    tile.click do
      toggle_selected(@g.hand.size - 1)
    end
    toggle_selected(@g.hand.size - 1)
  end

  def discard
    info "discard [#{@selected}] - #{@g.hand[@selected]}"
    @discards.append do
      layout_tile(@g.hand[@selected], width: TILE_WIDTH, margin: 0)
    end
    @g.hand.delete_at @selected
    clear_selection
    @g.hand.sort!
    refresh_hand
  end

  def layout_tile(tile_name, width:, left: nil, margin: 1, margin_left: nil)
    stack(:width => width, :left => left, :margin => margin, :margin_left => margin_left) do
      border black
      image("images/#{tile_name}.png", :width => width - margin * 2)
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
    @hand = flow :margin_top => 40, :margin_bottom => 40

    flow do
      @discards = flow :width => 700
      stack :width => 200 do
        flow do
          @draw_button = button "Draw" do
            @hand.append do
              draw
            end
            refresh
          end
          @discard_button = button "Discard" do
            discard
            @hand.append do
              draw
            end
            refresh
          end
          button "Restart" do
            @hand.clear
            @arrangements.clear
            @discards.clear
            new_game
            refresh_hand
          end
        end
        @remaining = caption "remaining: #{@g.deck.size}"
      end

    end
  end

  @arrangements = stack

  refresh_hand

  keypress do |key|
    if key == "r"
      @hand.clear
      @arrangements.clear
      @discards.clear
      new_game
      refresh_hand
    end
  end
end
