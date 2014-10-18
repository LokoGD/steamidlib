# SteamIDLib

I doubt anyone sane will be able to understand my library because I spent a good half hour reading through [the specification for SteamIDs](https://developer.valvesoftware.com/wiki/SteamID) and making sure I got everything right the first time.

Look through `lib/steamidlib.rb` for some in-line documentation on how to do things and what things are. Every method is documented and states clearly what it does and what the output should look like.

Make sure to *not* use `SteamID64.accountID64` unless you fully understand what you are doing! It can be misleading.

The test suite sucks and is bad. But it works when Steamidlib works and it doesn't when Steamidlib doesn't, so it's Good Enough™. But it still sucks.

# Installation
Do `gem install steamidlib.` Then, do `require 'steamidlib'` wherever you need to use it.
Otherwise, do
```
gem build steamidlib.gemspec
gem install steamidlib-1.0.1.gem
```

# Usage
If you find having to use `SteamIDs::foo` is too hard, try using `include SteamIDs`. Look through the test suite for some examples on how to use Steamidlib. It's at `test/test_steamidlib.rb`.

### FAQ

> Why is this any better than SteamIDConverter?

Because SteamIDConverter doesn't let you convert any SteamIDs other than individual ones.

> Why not just use the Steam API?

Because then you need network API calls which block. This is just math.

> Why?

Why not?
