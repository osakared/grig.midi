# grig.midi

[![pipeline status](https://gitlab.com/haxe-grig/grig.midi/badges/main/pipeline.svg)](https://gitlab.com/haxe-grig/grig.midi/commits/main)
[![Build Status](https://travis-ci.org/osakared/grig.midi.svg?branch=main)](https://travis-ci.org/osakared/grig.midi)
[![Gitter](https://badges.gitter.im/haxe-grig/Lobby.svg)](https://gitter.im/haxe-grig/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

See the [haxe grig documentation](https://grig.tech/).

Stuff for working with midi data and midi files.

## Instructions

To install latest version from haxelib

`lix install haxelib:grig.midi`

or

`haxelib install grig.midi`

### c++

Make sure alsa-dev is installed on your system if you're on linux and building hxcpp version. Probably need it for other bindings as well.

If you want to use jack, you must have jack2 client on your system and set it enabled when building. For example (with the MidiOutput example):

`haxe build.hxml -D enable_jack -cpp bin/MidiWriter`

### python

Install python-rtmidi if you want midi port support:

`pip install python-rtmidi`

### nodejs

Install midi if you want midi port support:

`sudo npm install midi -g --python=/usr/bin/python2.7 --unsafe-perm`
