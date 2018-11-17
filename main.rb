require 'bundler/setup'
require 'riichi'

# Harness for debugging until I get debugging working in tests

# tiles = Riichi::Tiles.from_s("7s 8s 8s 8s 9s 1m").tiles
# puts Riichi::Tiles.chow_start?(tiles)


# ["1p 3p 9p 3s 7s 8s 8s 8s 9s 1m 2m 3m 6m S",
#   ["7s 8s 9s", "8s 8s 8s", "1m 1m 3m"]]

class Array
  def to_tile_strings
    self.map do |x|
      case x
      when Riichi::Tile then x.to_s
      when Array then x.to_tile_strings
      else x
      end
    end
  end
end

[
  "1s 1s 1s 2s 2s 2s",
  "1s 1s 1s 2s 3s",
  "1s 1s 1s 2s 3s 5m 6m 7m",
  "1s 1s 1s 2s 3s 4s N",
].each do |s|
  puts "Tiles: #{s}"
  arrangements = Riichi::Tiles.arr(s)
  # p x.to_tile_strings
  puts "==>"
  arrangements.each_with_index do|arr, i|
    puts "arrangement <#{i}>"
    arr.each do |set|
      puts "   set: #{set.to_tile_strings.inspect}"
    end
  end
  puts "--\n\n"
end

# t2 = "5p 7p 8p 9p 1s 1s 3s 5s 1m 2m 3m 3m 4m N"
# tiles = Riichi::Tiles.from_s(t2)
# puts "Computing sets for #{tiles}"
# puts tiles.sets.map { |a| "[#{a.join', '}]"}
