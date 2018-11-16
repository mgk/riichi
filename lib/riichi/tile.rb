module Riichi
  class Tile
    include Comparable

    attr_reader :type, :suit, :rank, :wind, :dragon, :str

    def initialize(type: nil, suit: nil, rank: nil, wind: nil, dragon: nil, str: nil)
      @type = type
      @suit = suit
      @rank = rank
      @wind = wind
      @dragon = dragon
      @str = str

      freeze
    end

    def to_s
      str
    end

    def self.from_s(str)
      @tiles_by_str.fetch(str)
    end

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

    def next_in_suit
      if suited? && rank < 9
        Tile.from_s("#{rank + 1}#{suit[0]}")
      end
    end

    def <=>(other)
      self.type <=> other&.type
    end

    def self.tile_types
      suited_tiles = [:pinzu, :sozu, :manzu].flat_map do |suit|
        (1..9).map do |rank|
          Tile.new(suit: suit, rank: rank, str: "#{rank}#{suit[0]}")
        end
      end

      honors = [
        Tile.new(wind:   :east,  str: 'E'),  # 東
        Tile.new(wind:   :south, str: 'S'),  # 南
        Tile.new(wind:   :west,  str: 'W'),  # 西
        Tile.new(wind:   :north, str: 'N'),  # 北
        Tile.new(dragon: :red,   str: 'C'),  # 中 - (pinyin chung)
        Tile.new(dragon: :white, str: 'B'),  # 白 - (pingyin bai)
        Tile.new(dragon: :green, str: 'F'),  # 發 - (pinyin fa)
      ]

      (suited_tiles + honors).each_with_index.map do |t, i|
        Tile.new(type: i,
                 str: t.str,
                 suit: t.suit,
                 rank: t.rank,
                 wind: t.wind,
                 dragon: t.dragon)
      end
    end

    def self.deck
      @deck
    end

    @tiles_by_str = tile_types.map { |tt| [tt.str, tt] }.to_h
    @deck = tile_types * 4
    freeze
  end

end
