package grig.midi;

#if (nodejs || python)
typedef MidiOut = grig.midi.rtmidi.MidiOut;
#else

extern class MidiOut
{
    public function new();
    public function getPorts():Array<String>;
    public function openPort(portNumber:Int, portName:String):Void;
    public function openVirtualPort(portName:String):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function sendMessage(midiMessage:MidiMessage):Void;
}

#end