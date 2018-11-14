require 'riichi/tile'

module Riichi
  class Tiles

    attr_reader :tiles

    def initialize(tiles)
      @tiles = tiles.sort
      freeze
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
      def aux(acc, remaining)
        if remaining.empty?
          return acc
        end

        candidate = remaining.take(3)

        if Tile.set?(candidate)
          aux(acc + [candidate], remaining.drop(1))
        else
          aux(acc, remaining.drop(1))
        end
      end
      aux([], @tiles)
    end

  end
end