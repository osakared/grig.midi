# grig.midi

[![pipeline status](https://gitlab.com/haxe-grig/grig.midi/badges/master/pipeline.svg)](https://gitlab.com/haxe-grig/grig.midi/commits/master)
[![Build Status](https://travis-ci.org/osakared/grig.midi.svg?branch=master)](https://travis-ci.org/osakared/grig.midi)
[![Gitter](https://badges.gitter.im/haxe-grig/Lobby.svg)](https://gitter.im/haxe-grig/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

See the [haxe grig documentation](https://haxe-grig.gitlab.io/grig/).

Stuff for working with midi data and midi files.

## Todo

* Writing midi files (we have reading already)
* Support for hardware ports for targets that support it (we have this on python target already)
* Install packages automatically somehow (make instructions unnecessary)

## Instructions

`git submodule init && git submodule update` to get external dependencies.

Make sure alsa-dev is installed on your system if you're on linux and building hxcpp version. Probably need it for other bindings as well.

### python

Install python-rtmidi if you want midi port support:

`pip install python-rtmidi`

### nodejs

Install midi if you want midi port support:

`sudo npm install midi -g --python=/usr/bin/python2.7 --unsafe-perm`