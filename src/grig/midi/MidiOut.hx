package grig.midi;

extern class MidiOut
{
    public function new();
    public function getPorts():Array<String>;
    public function openPort(portNumber:Int, portName:String):Void;
    public function openVirtualPort(portName:String):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function cancelCallback():Void;
    public function sendMessage(midiMessage:MidiMessage):Void;
}