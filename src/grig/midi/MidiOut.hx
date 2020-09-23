package grig.midi;

import tink.core.Future;

#if (cpp && !DISABLE_RTMIDI)
typedef MidiOut = grig.midi.cpp.rtmidi.MidiOut;
#elseif (python && !DISABLE_RTMIDI)
typedef MidiOut = grig.midi.python.rtmidi.MidiOut;
#elseif (nodejs && !DISABLE_RTMIDI)
typedef MidiOut = grig.midi.js.rtmidi.MidiOut;
#elseif (cs && !DISABLE_MANAGEDMIDI)
typedef MidiOut = grig.midi.cs.managedmidi.MidiOut;
#elseif (js && !DISABLE_WEBMIDI)
typedef MidiOut = grig.midi.js.webmidi.MidiOut;
#elseif (java && !DISABLE_JAVAX_MIDI)
typedef MidiOut = grig.midi.java.MidiOut;
#else

/**
 * Generic midi out interface that abstracts over different apis depending on the target.
 * See [grig's website](https://grig.tech/midi-connection/) for a tutorial on basic use.
 */
extern class MidiOut implements MidiSender
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
