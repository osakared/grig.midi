package grig.midi.webmidi; #if (js && !nodejs)

import js.Promise;

@:native('Navigator')
extern class Navigator
{
    function requestMIDIAccess():Promise<MIDIAccess>;
}

#end