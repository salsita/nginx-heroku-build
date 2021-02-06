# Nginx binaries builds for Heroku

## About

* Dynamically linked, with lua, http2, geoip etc., built in Heroku build docker images.
* Bins committed to the repository, being downloaded by Heroku runtime (saving bucks on S3 traffic).
* Comes with `mime.types`.
* *Be careful what you do on master branch.*
* Nginx compile options changable in `scripts/build-nginx.sh`.
* Inspired by https://github.com/Americastestkitchen/heroku-buildpack-nginx

## Usage

* Requires `docker`.

```
make <shell|build[-cedar-14|-heroku-[16,18,20]]
```

* Result in `bin/`.

## Heroku 20 commentary

Due to compatibility reasons, nginx bin for heroku-20 stack is built on heroku-18 build docker image.
It uses latest nginx available (`1.19.6` at the time of update), a bit older gcc to actually build it and a bit older nginx dev kit
and lua in order to run nginx with lua without any other dependencies needed (LuaJIT2 e.g.).
*Compatible with heroku-18 stack.*

### Current nginx Heroku 20 runtime requirements

* Folder `/tmp/nginx/log`.

### Running Heroku 20 nginx

```
./nginx -p . -c </path/to/conf>
```

### Working example

```
#!/bin/bash

set -e

erb heroku/nginx.conf.erb > heroku/nginx.conf

mkdir -p /tmp/nginx/log
( cd /tmp/nginx/log && touch access.log error.log )

( tail -qF -n 0 /tmp/nginx/log/*.log ) & # get nginx logs directly into Heroku logs

curl -sSL https://github.com/salsita/nginx-heroku-build/raw/master/bin/nginx-heroku-20 \
  > nginx
chmod +x nginx

curl -sSL https://raw.githubusercontent.com/salsita/nginx-heroku-build/master/mime.types \
  > heroku/mime.types

echo Starting nginx
./nginx -p . -c heroku/nginx.conf
```

* `heroku/nginx.conf` contains full nginx configuration (as `/etc/nginx/nginx.con` does, sites included).
