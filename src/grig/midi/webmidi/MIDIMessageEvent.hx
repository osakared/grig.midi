package grig.midi.webmidi; #if (js && !nodejs)

@:native('MIDIMessageEvent')
extern class MIDIMessageEvent
{
    var data:js.html.Uint8Array;
    var timeStamp:Float;
}

#end