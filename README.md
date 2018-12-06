# Riichi

Richii Mah Jong hand calculator.

To experiment, run `bin/console` for an interactive prompt.

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

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'riichi'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install riichi
```

## Usage

TODO: Write usage instructions here

## Development

### Continuous Testing

```bash
gem install filewatcher
filewatcher "lib spec" rake
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mgk/riichi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Symbols

https://en.wikipedia.org/wiki/Mahjong_tiles

### Individual Tile Symbols

There are unicode points for each tile but they do not work well in most contexts.

### Character Symbols
- 筒 pinzu  ( maybe visual use ⨷ )
- 索 sozu   ( maybe visual use ‖ )
- 萬 manzu

- 東 east ton
- 南 south nán
- 西 west shā
- 北 north pei

- 中 red chun
- 發 green haku
- 白 white hatsu
