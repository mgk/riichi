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

    def self.diff(a, b)
      (Tiles.new(a) - Tiles.new(b)).tiles
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

    def self.chow(tile)
      [tile, tile.next_in_suit, tile.next_in_suit.next_in_suit]
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
        if tiles[next_idx] == tiles[curr_idx].next_in_suit
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

    def sets
      []
    end

    def self.matches?(set, tile)
      set.empty? ||
      (set.length == 1 && tile == set.last || tile == set.last.next_in_suit) ||
      Tiles.set?(set + [tile])
    end

    def self.arr(str)
      _arr(0, [], [], Tiles.from_s(str).tiles)
    end

    # acc - list of arrangements
    # arrangement - list of sets
    # set - list of tiles
    def self._arr(level, acc, arrangement, remaining)
      puts
      pr = lambda do |s|
        if level == 0
          puts ("(#{level}) " + "    " * level) + s
        end
      end
      pr.call("       acc: #{acc.to_tile_strings}")
      pr.call("arrangement: #{arrangement.to_tile_strings}")
      pr.call(" remaining: #{remaining.to_tile_strings}")
      if remaining.empty?
        pr.call("      ans1: #{acc.to_tile_strings}")
        return acc + [arrangement]
      end

      isets = initial_sets(remaining)
      pr.call("     isets: #{isets.to_tile_strings}")

      combos = isets.map {|c| [c, Tiles.diff(remaining, c)]}
      pr.call("    combos: #{combos.to_tile_strings}")

      if combos.empty?
        pr.call("      empty")
        return _arr(level + 1, acc, arrangement, remaining.drop(1))
      else
        ans = combos.flat_map do |set, rest|
          pr.call("     combo: #{set.to_tile_strings}--#{rest.to_tile_strings}")
          cans = _arr(level + 1, acc, arrangement + [set], rest)
          pr.call("combo ans: #{cans.to_tile_strings}")
          cans
        end

        pr.call("      ans2: #{ans.to_tile_strings}")
        return ans
      end
    end

  end

  class Arr
    attr_accessor :sets, :strays
    def initialize(sets, strays)
      @sets = sets
      @strays = strays
    end
    def to_s
      "sets: #{sets.to_tile_strings}, strays: #{strays.to_tile_strings}"
    end
  end
end
