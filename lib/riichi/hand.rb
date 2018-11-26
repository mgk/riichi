module Riichi

  class Hand

    # @return [Array<Tiles>] unmelded tiles in the hand
    attr_reader :tiles

    # @return [Array<Array<Tiles>>] open melds in the hand
    attr_reader :melds

    # @return [Array<Tiles>] tiles discarded from the hand
    attr_reader :discards

    # @return [:east, :south, :west, :north] the prevailing wind
    attr_reader :bakaze

    # @return [:east, :south, :west, :north] the seat wind
    attr_reader :jikaze

    def initialize(tiles, bakaze: :east, jikaze: :east, melds: [], discards: [])
      @tiles = case tiles
      when String then Tile.to_tiles(tiles)
      when Array then tiles
      end.sort

      if !valid?
        raise ArgumentError, @tiles
      end
      @bakaze = bakaze
      @jikaze = jikaze
      @melds = melds
      @discards = discards
    end

    def valid?
      @tiles.group_by { |x| x }.values.map(&:length).all? { |count| count <= 4 }
    end

    def open?
      @melds.empty?
    end

    def closed?
      !open?
    end

    def value_tiles
      [Tile.get(dragon: :red), Tile.get(dragon: :white), Tile.get(dragon: :green),
        Tile.get(wind: bakaze), Tile.get(wind: jikaze)]
    end

    # Determines if the hand is complete
    #
    # @return [true, false] if the hand is complete
    def complete?
      !complete_arrangements.empty?
    end

    # Determines all the arrangements which make the hand complete.
    #
    # @return [Array<Array<Tile>] Complete arragements, each
    # arrangement includes the final pair if any.
    def complete_arrangements
      if tiles.length % 3 != 2
        return []
      end

      if Tile.pair?(tiles)
        return [tiles]
      end

      Tile.arrangements(tiles)
      .map do |arrangement|
        unmatched = Tile.diff(tiles, arrangement)
        [arrangement, unmatched]
      end
      .find_all { |arrangement, unmatched| Tile.pair?(unmatched) }
      .map do |arragement, pair|
        arragement + [pair]
      end
    end

    def to_s
      # This might be nicer, need to reconcile with Tile.to_s
      # suited = @tiles.find_all(&:suited?).group_by(&:suit).map do |suit, tiles|
      #   "#{suit[0]}#{tiles.map(&:rank).join}"
      # end.join(" ")
      "tiles: #{tiles}, open: #{melds}, discards: #{discards}"
    end

    def yaku
      if !complete?
        return nil
      end
      complete_arrangements.map do |arrangement|
        [
          :tanyao,
          :yakuhai,
        ]
        .map do |hand_type|
          [arrangement, [hand_type, self.method(hand_type).call(arrangement)]]
        end
        .find_all do |arr, y|
          y[1] > 0
        end
      end
    end

    def tanyao(arrangement)
      all_simple = (melds + arrangement).all? do |set|
        set.all? { |tile| tile.simple? }
      end
      all_simple ? 1 : 0
    end

    def yakuhai(arrangement)
      triples = (melds + arrangement).find_all { |s| s.length == 3 }
      triples.sum do |triple|
        value_tiles.count do |value_tile|
          triple[0] == value_tile
        end
      end
    end
  end

end
