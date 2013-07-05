# Teletask-cli
## What?

My university, the Hasso-Plattner-Institute in Potsdam/Germany, has an extensive online repository of recorded lecture videos at http://tele-task.de/. Sadly the website is not an engineering highlight. Thus most people just want to fetch the video assets and consume them in other ways. Boom, this script should help you.

## Installation

It's a ruby script. I used ruby 2.0 for development, but it should also run with ruby 1.9.x. Packet management is done via bundler.

```
  gem install bundler
  bundle install
```

To download videos you need the `wget` tool. It usually ships with your OS, otherwise you can use your favorite packet management tool to download it, e.g. via `brew install wget` or `apt-get install wget`.

## Features

As input you always need to provide a feed url. You can obtain the url from Teletask on the lecture page on the right top corner. It's not the rss-logo (`Lecture-Feed of Series`) but the iTunes-y cube next to it (`Feed of Series`).

### Feed to XSPF
  `ruby teletask-cli.rb --xspf http://tele-task.de/feeds/series/946/`
  `ruby teletask-cli.rb -x http://tele-task.de/feeds/series/946/`

  XSPF is a playlist format that can be read by many popular media players, e.g. VLC. It also accepts urls, thus you can stream right away.

  The cli option `--xspf` accepts a url to a series-feed on Teletask. The generated `output.xspf` links directly to the .mp4 assets on the Teletask servers. You should be able to drag-and-drop the xspf playlist into your favorite player and stream the videos directly.

### Download videos
  `ruby teletask-cli.rb --download http://tele-task.de/feeds/series/946/`
  `ruby teletask-cli.rb -d http://tele-task.de/feeds/series/946/`

  You can download all .mp4 video assets by using the `-x` cli option with the feed url. The files will be saved with the original file names in the folder you executed the script in. Downloading happens via `wget`.

## Contributing
Fork away. I'm happy to accept pull requests, there is a lot of stuff to be added.

