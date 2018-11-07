package grig.midi.rtmidi;

@:pythonImport('rtmidi', 'MidiOut')
@:native('MidiOut')
extern class NativeMidiOut
{
    public function new();
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function send_message(message:Array<Int>):Void;
}

class MidiOut
{
    private var midiOut:NativeMidiOut;

    public function new()
    {
        midiOut = new NativeMidiOut();
    }

    public function getPorts():Array<String>
    {
        return midiOut.get_ports();
    }

    public function openPort(portNumber:Int, portName:String):Void
    {
        midiOut.open_port(portNumber, portName);
    }

    public function openVirtualPort(portName:String):Void
    {
        midiOut.open_virtual_port(portName);
    }

    public function closePort():Void
    {
        midiOut.close_port();
    }

    public function isPortOpen():Bool
    {
        return midiOut.is_port_open();
    }

    public function sendMessage(message:MidiMessage):Void
    {
        var messageArray = new Array<Int>();
        messageArray.push(message.byte1);
        messageArray.push(message.byte2);
        messageArray.push(message.byte3);
        midiOut.send_message(messageArray);
    }
}