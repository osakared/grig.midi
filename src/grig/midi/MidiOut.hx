package grig.midi;

import tink.core.Future;

#if (nodejs || python || cpp)
typedef MidiOut = grig.midi.rtmidi.MidiOut;
#elseif js
typedef MidiOut = grig.midi.webmidi.MidiOut;
#else

/**
 * Generic midi out interface that abstracts over different apis depending on the target.
 * See [grig's website](https://grig.tech/midi-connection/) for a tutorial on basic use.
 */
extern class MidiOut
{
    public function new(api:grig.midi.Api);
    public static function getApis():Array<grig.midi.Api>;
    public function getPorts():Surprise<Array<String>, tink.core.Error>;
    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>;
    public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function sendMessage(midiMessage:MidiMessage):Void;
}

#end
