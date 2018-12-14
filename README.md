[![Build Status](https://travis-ci.org/mgk/riichi.svg?branch=master)](https://travis-ci.org/mgk/riichi)

# Riichi

Riichi Mahjong hand calculator. For info on what Riichi Mahjong is see:

- http://uspml.com/

I started this project to refresh my Ruby skills and practice scoring Mahjong hands.

Currently:

- determines possible arrangements of hands
- determines if hand qualifies for the common yaku
- has a simple UI that draws, discards, and sorts tiles

In progress:

- counting fu
- scoring that depends on hand actions (e.g., self drawn, 2 sided waits, ...)

## Installation

- install ruby 2.5 or JRuby
- check out git repo
- `bin/setup` to install dependencies

## Usage

- run GUI with `bin/run`.
- run `bin/console` for an IRB session with Richii loaded.

## Development

- `rake` - run tests with coverage
- `rake bench` - run benchmark
- `yard` - generate doc
- `rake clean` - remove generated files

### Continuous Testing

```bash
gem install filewatcher
filewatcher "lib spec" rake
```

## Symbols

https://en.wikipedia.org/wiki/Mahjong_tiles

### Individual Tile Symbols

There are unicode points for each tile but they do not work well in most contexts.

### Character Symbols
- 筒 pinzu  -- visual pretty printing uses: ⨷
- 索 sozu   -- visual pretty printing uses: ‖
- 萬 manzu  -- visual pretty printing uses: 萬

- 東 east ton
- 南 south nán
- 西 west shā
- 北 north pei

- 中 red chun
- 發 green haku
- 白 white hatsu

## TODO rare hands

- junchan
- sho san gen
- honroto
- ryan peiko
- koku shimusou 13 orphans
- chuuren pooto 9 gates
- suu anko
- ryuu iisou all green
- chinrouto all terminals
- tsu issou all honours
- dai sangen big 3 dragons
- shou suushi little 4 winds
- dai suushi big 4 winds
- draw dependent
- action dependent yaku

## Acknowledgements

A big thank you to [FluffyStuff](https://github.com/FluffyStuff/riichi-mahjong-tiles) for the tile images.