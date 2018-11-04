package grig.midi;

class MidiOut
{
    private var midiOut:grig.midi.rtmidi.MidiOut;

    public function new()
    {
        midiOut = new grig.midi.rtmidi.MidiOut();
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

    public function cancelCallback():Void
    {
        midiOut.cancel_callback();
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