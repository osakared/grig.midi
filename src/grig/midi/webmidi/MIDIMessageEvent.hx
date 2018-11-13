package grig.midi.webmidi;

@:native('MIDIMessageEvent')
extern class MIDIMessageEvent
{
    var data:js.html.Uint8Array;
    var timeStamp:Float;
}