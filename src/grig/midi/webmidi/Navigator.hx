package grig.midi.webmidi;

import js.Promise;

@:native('Navigator')
extern class Navigator
{
    function requestMIDIAccess():Promise<MIDIAccess>;
}