require 'riichi/tile'
require 'set'

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

module Riichi
  class Tiles
    include Comparable
    attr_reader :tiles

    def initialize(tiles)
      @tiles = tiles.sort
      freeze
    end

    def <=>(other)
      tiles <=> other.tiles
    end

    def to_s
      @tiles.join(' ')
    end

    def self.from_s(str)
      tiles = str.split(' ').map { |s| Tile.from_s(s) }
      Tiles.new(tiles)
    end

    # Subtract Tiles.
    #
    # @param [Array<Tile>] a minuend
    # @param [Array<Tile>, Array<Array<Tile>>] b subtrahend
    # @return a - b
    # @example
    #   def t(s); Tiles.from_s(s).tiles end
    #
    #   diff(t('1p 1p 2p 3p'), t('1p 2p')).to_s #=> "[1p 3p]"
    #   diff(t('1p 1p 2p 3p'), [t('1p'), t('1p 2p')]).to_s #=> "[3p]"
    def self.diff(a, b)
      answer = a.dup
      subtrahend = [b].flatten

      answer.delete_elements!(subtrahend)
      answer
    end

    def -(other)
      Tiles.new(Tiles.diff(tiles, other.tiles))
    end

    def self.pung?(tiles)
      tiles.size == 3 &&
      tiles[0] == tiles[1] &&
      tiles[1] == tiles[2]
    end

    def pung?
      self.pung? tiles
    end

    def self.chow(tile)
      [tile, tile.next_in_suit, tile.next_in_suit.next_in_suit]
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
            return chow(tiles[0])
          end
        else
          return nil
        end
      end

      nil

    end

    def self.initial_pung(tiles)
      pung = tiles[0, 3]
      pung if self.pung?(pung)
    end

    def self.initial_sets(tiles)
      [self.initial_chow(tiles), self.initial_pung(tiles)].compact
    end

    def self.chow?(tiles)
      tiles.size == 3 &&
      tiles.all? { |tile| tile.suited? } &&
      tiles.all? { |tile| tile.suit == tiles[0].suit } &&
      tiles[1].rank == tiles[0].rank + 1 &&
      tiles[2].rank == tiles[1].rank + 1
    end

    def chow?
      self.chow? tiles
    end

    def self.set?(tiles)
      pung?(tiles) || chow?(tiles)
    end

    def set?
      self.set? tiles
    end

    def self.matches?(set, tile)
      set.empty? ||
      (set.length == 1 && tile == set.last || tile == set.last.next_in_suit) ||
      Tiles.set?(set + [tile])
    end

    def self.arrangements(tile_input)
      tiles = case tile_input
        when String then Tiles.from_s(tile_input).tiles
        when Array then Tiles.new(tile_input).tiles
      end

      tiles = connectors(tiles)
      arrangements = _arr(0, [], [], tiles)
      _remove_non_maximal_arrangements(arrangements)
    end

    # an arrangement is non-maximal if it is a subset
    # of any other arrangement
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

    # acc - list of arrangements
    # arrangement - list of sets
    # set - list of tiles
    def self._arr(level, acc, arrangement, remaining)
      if remaining.empty?
        return acc + [arrangement]
      end

      # arrangements that use the first tile
      initial_arrangements = initial_sets(remaining).map do |set|
        [set, Tiles.diff(remaining, set)]
      end
      .flat_map do |set, rest|
        _arr(level + 1, acc, arrangement + [set], rest)
      end

      return initial_arrangements + _arr(level + 1, acc, arrangement, remaining.drop(1))
    end

  end

end
