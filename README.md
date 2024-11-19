# The Humans Are Rebelling!

My entry for the [7th Gosu Game Jam](https://itch.io/jam/gosu-game-jam-7). Basically a twist on the classic
[Berzerk](https://en.wikipedia.org/wiki/Berzerk_(video_game)) but worse :)

## How to play

### Installing

The easiest way is to download the game from [itch.io](https://chadow.itch.io/the-humans-are-rebelling#download) or here on the [GitHub releases](https://github.com/Chadowo/the-humans-are-rebelling/releases).

### Controls

- <kbd>↑</kbd> <kbd>←</kbd> <kbd>→</kbd> <kbd>↓</kbd> - Movement.  
- <kbd>Space</kbd> - Shoot!

## Development

Assuming you have [Ruby installed](https://www.ruby-lang.org/en/downloads/), then clone this repo:

```bash
$ git clone https://github.com/Chadowo/the-humans-are-rebelling.git
```

...and install the required gems with `bundle install`. Finally, to run the game just call `rake`.

While the game here works on CRuby, it is also *meant* to be compatible with
MRuby. That is, because I use the [Gosu MRuby wrapper](https://github.com/Chadowo/gosu-mruby-wrapper) to package the game for desktop platforms. This
means that we can't use `gem` to install and use libraries, to workaround that I bundle the gems used
by the game with the source code here.

Currently, I don't have an automated way of running nor packaging the game with the Gosu MRuby wrapper.
But I'll see what I can do in the future.

## License

### Assets

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) unless noted otherwise (see below).

#### Third-party

Unifont - [OFL 1.1 license](https://unifoundry.com/OFL-1.1.txt).

### Code

[MIT license](LICENSE).
