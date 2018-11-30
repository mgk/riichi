require 'tile'

module Riichi

  # A drawn tile
  class Draw < Tile

    def initialize(tsumo: false)
      @tsumo = tsumo
    end

    def tsumo?
      @tsumo
    end
  end

end