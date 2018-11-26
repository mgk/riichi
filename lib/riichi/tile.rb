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

    # @return [String] pretty string representation
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

    # @return [true, false] if honor tile
    def honour?
      wind? || dragon?
    end

    # @return [true, false] if wind tile
    def wind?
      wind
    end

    # @return [true, false] if dragon tile
    def dragon?
      dragon
    end

    # @return [true, false] if suited tile
    def suited?
      suit
    end

    # @return [true, false] if suited end tile
    def terminal?
      [1, 9].include? rank
    end

    # @return [true, false] if suited middle tile
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

    # Get the tile following this tile in the same suit.
    #
    # @return [Tile] the following tile or `nil` if self is not suited or is a 9
    def next_in_suit
      suited? && Tile.get(suit: suit, rank: rank + 1)
    end

    def <=>(other)
      self.type <=> other&.type
    end

    # Get the string representation of this tile.
    # @see Tile#to_tile
    # @return [String] the string
    def to_s
      str
    end

    def inspect
      str
    end

    # Get the tile for a string.
    #
    # @param [String] tile string, as returned by {Tile#to_s}
    # @return [Tile] the specified Tile
    def self.to_tile(tile)
      @tiles_by_str.fetch(tile)
    end

    def self.get(suit: nil, rank: nil, wind: nil, dragon: nil)
      case
      when suit then @tiles[[suit, rank]]
      when wind then @tiles[wind]
      when dragon then @tiles[dragon]
      end
    end

    def self.to_tiles(str)
      str.split(' ').map { |s| to_tile(s) }
    end

    def self.set?(tiles)
      pung?(tiles) || chow?(tiles)
    end

    def self.pung?(tiles)
      tiles.size == 3 &&
      tiles[0] == tiles[1] &&
      tiles[1] == tiles[2]
    end

    def self.chow?(tiles)
      tiles.size == 3 &&
      tiles.all? { |tile| tile.suited? } &&
      tiles.all? { |tile| tile.suit == tiles[0].suit } &&
      tiles[1].rank == tiles[0].rank + 1 &&
      tiles[2].rank == tiles[1].rank + 1
    end

    def self.chow_from(tile)
      [tile, tile.next_in_suit, tile.next_in_suit.next_in_suit]
    end

    def self.initial_sets(tiles)
      [self.initial_chow(tiles), self.initial_pung(tiles)].compact
    end

    def self.initial_pung(tiles)
      pung = tiles[0, 3]
      pung if self.pung?(pung)
    end

    def self.initial_chow(tiles)
      sequence_length = 1
      curr_idx = 0
      next_idx = 1

      while tiles[next_idx] do
        # advance past duplicates
        while tiles[next_idx] == tiles[curr_idx] do
          curr_idx += 1
          next_idx += 1
        end

        # update if sequence continues with next tile
        if tiles[next_idx] && tiles[next_idx] == tiles[curr_idx].next_in_suit
          sequence_length += 1
          curr_idx = next_idx
          next_idx += 1
          if sequence_length == 3
            return chow_from(tiles[0])
          end
        else
          return nil
        end
      end

      nil

    end

    # Subtract Tiles.
    #
    # @param [Array<Tile>] a minuend
    # @param [Array<Tile>, Array<Array<Tile>>] b subtrahend
    # @return a - b
    # @example
    #   def t(s); Tiles.tile(s) end
    #
    #   diff(t('1p 1p 2p 3p'), t('1p 2p')).to_s #=> "[1p 3p]"
    #   diff(t('1p 1p 2p 3p'), [t('1p'), t('1p 2p')]).to_s #=> "[3p]"
    def self.diff(a, b)
      answer = a.dup
      subtrahend = [b].flatten

      answer.delete_elements!(subtrahend)
      answer
    end

    def self.pair?(tiles)
      tiles.length == 2 && tiles[0] == tiles[1]
    end


    # Determine the tiles that connect to at least one other
    # tile in a list.
    #
    # @param [Array<Tiles>] tiles tiles to check
    # @return [Array<Tiles>] tiles that connect to one or more
    # other tiles
    def self.connectors(tiles)
      tiles.each_with_index.find_all do |tile, idx|
        tile.connects?(tiles.fetch(idx - 1, nil)) ||
          tile.connects?(tiles.fetch(idx + 1, nil))
      end
      .map { |tile, idx| tile }
    end

    def self.arrangements(tiles)
      tiles = connectors(tiles.sort)
      arrangements = _arr(0, [], [], tiles)
      _remove_non_maximal_arrangements(arrangements)
    end

    # An arrangement is non-maximal if it is a subset
    # of any other arrangement.
    def self._remove_non_maximal_arrangements(arrangements)
      arrangements.reject { |x| x.empty? }
      .to_set
      .sort_by(&:length)
      .reverse
      .reduce([]) do |acc, arr|
        if acc.any? { |prev| prev.includes_all? arr }
          acc
        else
          acc + [arr]
        end
      end
    end
    private_class_method :_remove_non_maximal_arrangements

    # acc - list of arrangements
    # arrangement - list of sets
    # set - list of tiles
    def self._arr(level, acc, arrangement, remaining)
      if remaining.empty?
        return acc + [arrangement]
      end

      # arrangements that use the first tile
      initial_arrangements = initial_sets(remaining).map do |set|
        [set, Tile.diff(remaining, set)]
      end
      .flat_map do |set, rest|
        _arr(level + 1, acc, arrangement + [set], rest)
      end

      return initial_arrangements + _arr(level + 1, acc, arrangement, remaining.drop(1))
    end
    private_class_method :_arr

    def self._tile_types
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
    private_class_method :_tile_types

    def self.deck
      @deck
    end

    @tiles = _tile_types.map do |tile|
      key = case
      when tile.suited? then [tile.suit, tile.rank]
      when tile.wind? then tile.wind
      when tile.dragon? then tile.dragon
      end

      [key, tile]
    end.to_h.freeze

    @tiles_by_str = _tile_types.map { |t| [t.str, t] }.to_h.freeze

    @deck = (_tile_types * 4).freeze
    freeze
  end
end

class Array
  # Delete specified values. Unlike {#-} this method only deletes
  # the first instance of each specified value.

  # @example
  #   [1, 2, 2, 3].delete_elements!([1, 2, 42]) #=> [2, 3]
  #   [1, 2, 2, 3].delete_elements!([2, 2, 3]) #=> [1]
  def delete_elements!(arr)
    arr.each do |x|
      if index = index(x)
        delete_at(index)
      end
    end
  end

  # Determines if each of the values in the given array are contained
  # in self.
  #
  # @param [Array] other array to check
  # @return [true, false]
  # @example
  #   [1, 2].includes_all?([1, 2, 2]) #=> false
  #   [1, 2, 2].includes_all?([2, 2]) #=> true
  def includes_all?(other)
    leftovers = other.dup
    leftovers.delete_elements!(self)
    leftovers.empty?
  end
end
