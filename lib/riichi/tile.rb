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

    # @return [String] short string representation (honour tiles only)
    attr_reader :short

    def initialize(type: nil, suit: nil, rank: nil, wind: nil, dragon: nil, str: nil, pretty: nil, short: nil)
      @type = type
      @suit = suit
      @rank = rank
      @wind = wind
      @dragon = dragon
      @str = str
      @pretty = pretty
      @short = short
      freeze
    end
    private_class_method :new

    # @return [true, false] if honour tile
    def honour?
      wind? || dragon?
    end

    # @return [true, false] if wind tile
    def wind?
      !wind.nil?
    end

    # @return [true, false] if dragon tile
    def dragon?
      !dragon.nil?
    end

    # @return [true, false] if suited tile
    def suited?
      !suit.nil?
    end

    # @return [true, false] if suited end tile
    def terminal?
      [1, 9].include? rank
    end

    # @return [true, false] if suited middle tile
    def simple?
      suited? && !terminal?
    end

    # Determine if this tile connects to another tile. Two tiles
    # connect if they could be part of the same chow or pung.
    #
    # @param [Tile] other tile to check
    # @return [true, false] if the tiles connect
    def connects?(other)
      other &&
        (self == other ||
          (suited? &&
            suit == other.suit &&
            (rank - other.rank).abs <= 2))
    end

    # Get the tile following this tile in the same suit.
    #
    # @return [Tile] the following tile or `nil` if self is not suited or is a 9
    def next_in_suit
      suited? && Tile.get(suit: suit, rank: rank + 1)
    end

    def <=>(other)
      other.is_a?(Tile) ? self.type <=> other&.type : -1
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
      case tile
      when Tile then tile
      when String then @tiles_by_str.fetch(tile)
      end
    end

    def self.get(id: nil, suit: nil, rank: nil, wind: nil, dragon: nil)
      case
      when id then @tiles[id]
      when suit then @tiles[[suit, rank]]
      when wind then @tiles[wind]
      when dragon then @tiles[dragon]
      end
    end

    TILE_PATTERN = /(([mps][1-9]+)|[WGReswn])/

    # Parse tile string into array of short tiles.
    # The string can either be in regular long form
    # or in short form.
    #
    # @param [String] str string to Parse
    # @example
    #  long = "1p 1p 1p 1s 2s 3s Gd Rd Rd"
    #  short = "p111 s123 G RR"
    #  Tile.to_tiles(long) == Tile.to_tiles(short) #=> true
    # @return [Array<Tile>] tiles represented by str
    def self.to_tiles(str)
      return [] if str.empty?
      tiles = begin
        str.tr('-,', ' ').split(' ').map { |tile| Tile.to_tile(tile) }
      rescue
        str.tr('-_()[]{}', '').scan(TILE_PATTERN).map(&:first).flat_map do |match|
          if match.length == 1
            Tile.to_tile(match)
          else
            suit, *ranks = match.chars
            ranks.map { |rank| Tile.to_tile(rank + suit) }
          end
        end
      end
      raise ArgumentError, str if tiles.empty?
      tiles
    end

    def self.to_short_s(tiles)
      suited = [:manzu, :sozu, :pinzu].map do |suit|
        ranks = tiles.find_all { |t| t.suit == suit }.map(&:rank)
        ranks.empty? ? '' : "#{suit[0]}#{ranks.join('')}"
      end

      honours = [:east, :south, :west, :north, :white, :green, :red].map do |id|
        tiles.find_all { |t| t == @tiles[id] }.map(&:short).join('')
      end

      (suited + honours).reject(&:empty?).join(' ')
    end

    def self.set?(tiles)
      pung?(tiles) || chow?(tiles)
    end

    def self.pung?(tiles)
      tiles.size == 3 && tiles.all? { |t| t == tiles.first }
    end

    def self.kong?(tiles)
      tiles.size >= 4 && tiles.all? { |t| t == tiles.first }
    end

    def self.chow?(tiles)
      tiles.length == 3 &&
      tiles.all? { |tile| tile.suited? } &&
      tiles.all? { |tile| tile.suit == tiles[0].suit } &&
      tiles[1].rank == tiles[0].rank + 1 &&
      tiles[2].rank == tiles[1].rank + 1
    end

    def self.chow_from(tile)
      [tile, tile.next_in_suit, tile.next_in_suit.next_in_suit]
    end

    def self.pairs(tiles)
      pairs = tiles
        .group_by { |t| t }
        .find_all { |t, ts| ts.length == 2 }
        .map { |_, pair| pair }
      [pairs, Tile.diff(tiles, pairs)]
    end

    # Determine if self and the given tile form
    # a tatsu (i.e., 2 of 3 tiles in a chow).
    #
    # @param [Tile] tile other tile
    # @return [true, false] if the tiles form a tatsu
    def tatsu?(tile)
      self.connects?(tile) && self != tile
    end

    # Determine the tiles that would complete
    # a chow with the given tiles.
    #
    # @param [Array<Tile>] tiles array of 2 tiles
    # that may be a tatsu (2 of 3 tiles that make a chow)
    # @return [Array<Tile>] array of tiles that would complete
    # a chow with the given tiles, empty if tiles is not a tatsu.
    # @see #tatsu?
    def self.tiles_that_complete_chow(tiles)
      if !tiles[0].tatsu?(tiles[1])
        return []
      end

      tile1, tile2 = tiles.sort

      if tile2.rank == tile1.rank + 2
        [Tile.get(suit: tile1.suit, rank: tile1.rank + 1)]
      elsif tile2.rank == tile1.rank + 1
        [tile1.rank - 1, tile2.rank + 1]
        .find_all { |rank| rank.between?(1, 9 )}
        .map { |rank| Tile.get(suit: tile1.suit, rank: rank)}
      end
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

    # Determine all of the arrangements for an array of tiles.
    # An arrangement is an array of complete sets. Each
    # complete set is an array of tiles.
    #
    # @param [Array<Tiles>] tiles tiles to check
    # @return [Array<Array<Array<Tile>>] the possible arrangements
    def self.arrangements(tiles)
      tiles = tiles.sort
      specials = special_hand_arrangements(tiles)
      tiles = connectors(tiles)
      arrangements = _arr(0, [], [], tiles) + specials
      _remove_non_maximal_arrangements(arrangements)
    end

    # Determine all the special hand arrangements for tiles,
    # including the tenpai arrangements.
    #
    # @param [Array<Tiles>] tiles tiles to check
    # @return [Array<Array<Array<Tile>>] the possible arrangements
    def self.special_hand_arrangements(tiles)
      [self.chii_toi_arrangement(tiles),
       self.kokushimuso_arrangement(tiles)].compact
    end

    def self.chii_toi_arrangement(tiles)
      pairs, rest = self.pairs(tiles)
      pairs.length >= 6 && rest.length < 2 ? pairs : nil
    end

    def self.kokushimuso_arrangement(tiles)
      if tiles.any?(&:simple?)
        return nil
      end

      orphans = tiles.group_by { |tile| tile }.values

      if (tiles.length == 14 && orphans.length == 13) ||
        (tiles.length == 13 && orphans.length >= 12)
        orphans
      end
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
        [:manzu, '萬'], [:sozu, '‖'], [:pinzu, '⨷']
      ].flat_map do |suit, pretty|
        (1..9).map do |rank|
          new(suit: suit, rank: rank, str: "#{rank}#{suit[0]}", pretty: "#{rank}#{pretty}")
        end
      end

      honours = [
        new(wind:   :east,  str: 'Ew', pretty: '東', short: 'e'),
        new(wind:   :south, str: 'Sw', pretty: '南', short: 's'),
        new(wind:   :west,  str: 'Ww', pretty: '西', short: 'w'),
        new(wind:   :north, str: 'Nw', pretty: '北', short: 'n'),
        new(dragon: :white, str: 'Wd', pretty: '白', short: 'W'),
        new(dragon: :green, str: 'Gd', pretty: '發', short: 'G'),
        new(dragon: :red,   str: 'Rd', pretty: '中', short: 'R'),
      ]

      (suited_tiles + honours).each_with_index.map do |t, i|
        new(type: i + 1,
                 str: t.str,
                 pretty: t.pretty,
                 suit: t.suit,
                 rank: t.rank,
                 wind: t.wind,
                 dragon: t.dragon,
                 short: t.short)
      end
    end
    private_class_method :_tile_types

    def self.deck
      @deck
    end

    # tiles keyed by property
    @tiles = _tile_types.map do |tile|
      key = case
      when tile.suited? then [tile.suit, tile.rank]
      when tile.wind? then tile.wind
      when tile.dragon? then tile.dragon
      end

      [key, tile]
    end.to_h

    # tile aliases
    @tiles[:ton] = @tiles[:east]
    @tiles[:nan] = @tiles[:south]
    @tiles[:sha] = @tiles[:west]
    @tiles[:pei] = @tiles[:north]

    @tiles[:haku] = @tiles[:white]
    @tiles[:hatsu] = @tiles[:green]
    @tiles[:chun] = @tiles[:red]

    @tiles.freeze

    # tiles keyed by their string representations
    @tiles_by_str = _tile_types.map { |t| [t.str, t] }.to_h

    # honors also have short names
    by_short_name = @tiles_by_str.values.find_all(&:honour?).map do |t|
      [t.short, t]
    end.to_h
    @tiles_by_str.merge!(by_short_name)

    # suited tiles have two strings ('1m' and 'm1' for :manzu 1)
    suit_first = @tiles_by_str.values.find_all(&:suited?).map do |t|
      [t.to_s.reverse, t]
    end.to_h
    @tiles_by_str.merge!(suit_first)

    @tiles_by_str.freeze


    # a full deck is 4 of eack tile
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
