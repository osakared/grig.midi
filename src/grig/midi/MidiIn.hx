package grig.midi;

import tink.core.Future;

#if (nodejs || python)
typedef MidiIn = grig.midi.rtmidi.MidiIn;
#elseif js
typedef MidiIn = grig.midi.webmidi.MidiIn;
#else

extern class MidiIn
{
    public function new();
    public function getPorts():Surprise<Array<String>, tink.core.Error>;
    public function openPort(portNumber:Int, portName:String):Surprise<Void, tink.core.Error>;
    public function openVirtualPort(portName:String):Surprise<Bool, tink.core.Error>;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function setCallback(callback:(MidiMessage, Float)->Void):Void;
    public function cancelCallback():Void;
}

#end
