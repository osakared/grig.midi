package grig.midi;

import tink.core.Future;

#if (nodejs || python)
typedef MidiOut = grig.midi.rtmidi.MidiOut;
#elseif js
typedef MidiOut = grig.midi.webmidi.MidiOut;
#else

extern class MidiOut
{
    public function new();
    public function getPorts():Surprise<Array<String>, tink.core.Error>;
    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>;
    public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function sendMessage(midiMessage:MidiMessage):Void;
}

#end