package grig.midi.rtmidi;

import python.Tuple;

@:pythonImport('rtmidi', 'MidiIn')

@:native('MidiIn')
extern class MidiIn
{
    public function new();
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function set_callback(callback:(midiMessage:Tuple2<Array<Int>, Float>, data:Dynamic)->Void, data:Dynamic = Null):Void;
    public function cancel_callback():Void;
}
