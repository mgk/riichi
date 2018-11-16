require 'riichi/tile'

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

    def -(other)
      result = tiles.dup
      other.tiles.each do |t|
        if (index = result.index(t))
          result.delete_at(index)
        end
      end
      Tiles.new(result)
    end

    def self.pung?(tiles)
      tiles.size == 3 &&
      tiles[0] == tiles[1] &&
      tiles[1] == tiles[2]
    end

    def pung?
      self.pung? tiles
    end

    def self.chow?(tiles)
      tiles.size == 3 &&
      tiles.all? { |tile| tile.suited? } &&
      tiles.all? { |tile| tile.suit == tiles[0].suit } &&
      tiles[1].rank == tiles[0].rank + 1 &&
      tiles[2].rank == tiles[1].rank + 1
    end

    def self.chow_start?(tiles)
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
        if tiles[next_idx] == tiles[curr_idx].next_in_suit
          sequence_length += 1
          curr_idx = next_idx
          next_idx += 1
          if sequence_length == 3
            return true
          end
        else
          return false
        end
      end

      if tiles[1] != first
        return false
      end

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

    def sets
      _sets([], @tiles)
    end

    private def _sets(acc, remaining)
      if remaining.empty?
        return acc
      end

      candidate = remaining.take(3)
      rest = remaining.drop(1)

      if Tiles.set?(candidate)
        _sets(acc + [candidate], rest)
      else
        _sets(acc, rest)
      end
    end

  end
end