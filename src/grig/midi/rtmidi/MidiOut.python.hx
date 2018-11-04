package grig.midi.rtmidi;

@:pythonImport('rtmidi', 'MidiOut')

@:native('MidiOut')
extern class MidiOut
{
    public function new();
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function cancel_callback():Void;
    public function send_message(message:Array<Int>):Void;
}
