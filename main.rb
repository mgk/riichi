require 'bundler/setup'
require 'riichi'

# Harness for debugging until I get debugging working in tests

# tiles = Riichi::Tiles.from_s("7s 8s 8s 8s 9s 1m").tiles
# puts Riichi::Tiles.chow_start?(tiles)


# ["1p 3p 9p 3s 7s 8s 8s 8s 9s 1m 2m 3m 6m S",
#   ["7s 8s 9s", "8s 8s 8s", "1m 1m 3m"]]

t2 = "5p 7p 8p 9p 1s 1s 3s 5s 1m 2m 3m 3m 4m N"
tiles = Riichi::Tiles.from_s(t2)
puts tiles.sets
