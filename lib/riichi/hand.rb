module Riichi

  class Hand

    # @return [Array<Tiles>] unmelded tiles in the hand
    attr_reader :tiles

    # @return [Array<Array<Tiles>>] open sets in the hand
    attr_reader :open_melds

    # @return [Array<Tiles>] tiles discarded from the hand
    attr_reader :discards

    def initialize(tiles, open_melds: [], discards: [])
      @tiles = case tiles
      when String then Tile.to_tiles(tiles)
      when Array then tiles
      end.sort
      @open_melds = open_melds
      @discards = discards
    end

    def open?
      @open_melds.empty?
    end

    def closed?
      !open?
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
      "tiles: #{tiles}, open: #{open_melds}, discards: #{discards}"
    end

    def yaku
      if !complete?
        return nil
      end
      complete_arrangements.map do |arrangement|
        [
          :tanyao
        ]
        .map do |y|
          [arrangement, [y, self.method(y).call(arrangement)]]
        end
        .find_all do |arr, y|
          y[1] > 0
        end
      end
    end

    def tanyao(arrangement)
      all_simple = (open_melds + arrangement).all? do |set|
        set.all? { |tile| tile.simple? }
      end
      all_simple ? 1 : 0
    end

  end

end
