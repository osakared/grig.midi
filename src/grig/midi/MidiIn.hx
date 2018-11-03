package grig.midi;

extern class MidiIn
{
    public function new();
    public function getPorts():Array<String>;
    public function openPort(portNumber:Int, portName:String):Void;
    public function openVirtualPort(portName:String):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function setCallback((MidiMessage, Float)->Void):Void;
    public function cancelCallback():Void;
}
