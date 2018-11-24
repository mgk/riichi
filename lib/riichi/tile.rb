module Riichi
  class Tile
    include Comparable

    # @return [Integer] unique identifier of the tile type.
    attr_reader :type

    # @return [Symbol] suit identifier (:pinzu, :sozu, or :manzu) if suited
    attr_reader :suit

    # @return [Integer] rank if suited
    attr_reader :rank

    # @return [:east, :south, :west, :north] wind identifier if wind
    attr_reader :wind

    # @return [:red, :white, :green] dragon identifier if dragon
    attr_reader :dragon

    # @return [String] string representation
    attr_reader :str

    # @return [String] visual String representation
    attr_reader :pretty

    def initialize(type: nil, suit: nil, rank: nil, wind: nil, dragon: nil, str: nil, pretty: nil)
      @type = type
      @suit = suit
      @rank = rank
      @wind = wind
      @dragon = dragon
      @str = str
      @pretty = pretty
      freeze
    end

    def to_s
      str
    end

    def inspect
      str
    end

    def self.from_s(str)
      @tiles_by_str.fetch(str)
    end

    # @return [true, false] if honor tile
    def honour?
      wind || dragon
    end

    def suited?
      suit
    end

    def terminal?
      [1, 9].include? rank
    end

    def simple?
      suit && !terminal?
    end

    # Determine if this tile connects to another tile. Two tiles
    # connect if they could be part of the same chow or pung.
    #
    # @param [Tile] other tile to check
    # @return [true, false] if the tiles connect
    def connects?(other)
      other &&
        (self == other ||
          (suit && suit == other.suit && (rank - other.rank).abs <= 2))
    end

    def next_in_suit
      if suited? && rank < 9
        Tile.from_s("#{rank + 1}#{suit[0]}")
      end
    end

    def <=>(other)
      self.type <=> other&.type
    end

    def self.tile_types
      suited_tiles = [
        [:pinzu, '⨷'], [:sozu, '‖'], [:manzu, '萬']
      ].flat_map do |suit, pretty|
        (1..9).map do |rank|
          Tile.new(suit: suit, rank: rank, str: "#{rank}#{suit[0]}", pretty: "#{rank}#{pretty}")
        end
      end

      honors = [
        Tile.new(wind:   :east,  str: 'Ew', pretty: '東'),
        Tile.new(wind:   :south, str: 'Sw', pretty: '南'),
        Tile.new(wind:   :west,  str: 'Ww', pretty: '西'),
        Tile.new(wind:   :north, str: 'Nw', pretty: '北'),
        Tile.new(dragon: :red,   str: 'Rd', pretty: '中'),
        Tile.new(dragon: :white, str: 'Wd', pretty: '白'),
        Tile.new(dragon: :green, str: 'Gd', pretty: '發'),
      ]

      (suited_tiles + honors).each_with_index.map do |t, i|
        Tile.new(type: i + 1,
                 str: t.str,
                 pretty: t.pretty,
                 suit: t.suit,
                 rank: t.rank,
                 wind: t.wind,
                 dragon: t.dragon)
      end
    end

    def self.deck
      @deck
    end

    @tiles_by_str = tile_types.map { |tt| [tt.str, tt] }.to_h.freeze
    @deck = (tile_types * 4).freeze
    freeze
  end

end
