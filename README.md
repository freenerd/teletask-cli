# Teletask-cli
## What?

My university, the Hasso-Plattner-Institute in Potsdam/Germany, has an extensive online repository of recorded lecture videos at http://tele-task.de/. Sadly the website is not an engineering highlight. Thus most people just want to fetch the video assets and consume them in other ways. Boom, this script should help you.

## Installation

It's a ruby script. I used ruby 2.0 for development, but it should also run with ruby 1.9.x. Packet management is done via bundler.

```
  gem install bundler
  bundle install
```

## Features
### Feed to XSPF
  `ruby teletask-cli.rb --feed http://tele-task.de/feeds/series/946/`

  XSPF is a playlist format that can be read by many popular media players, e.g. VLC. It also accepts urls, thus you can stream right away.

  The cli option `--feed` accepts a url to a series-feed on tele-task. You can obtain the url on the lecture page on the right top corner. It's not the rss-logo (Lecture-Feed of Series) but the iTunes-y cube next to it (Feed of Series). The generated 'output.xspf' links directly to the .mp4 assets on the teletask server.

## Contributing
Fork away. I'm happy to accept pull requests, there is a lot of stuff to be added.

