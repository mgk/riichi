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

    def sets
      _sets([], @tiles)
    end

    private def _sets(acc, remaining)
      if remaining.empty?
        return acc
      end

      candidate = remaining.take(3)
      rest = remaining.drop(1)

      if Tile.set?(candidate)
        _sets(acc + [candidate], rest)
      else
        _sets(acc, rest)
      end
    end

  end
end