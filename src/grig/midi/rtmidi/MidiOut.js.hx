package grig.midi.rtmidi;

@:jsRequire('midi','output')
extern class NativeMidiOut
{
    public function new();
    public function getPortCount():Int;
    public function getPortName(index:Int):String;
    public function openPort(portNumber:Int, portName:String):Void;
    public function openVirtualPort(portName:String):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function sendMessage(message:Array<Int>):Void;
}

class MidiOut
{
    private var output:NativeMidiOut;

    public function new()
    {
        output = new NativeMidiOut();
    }

    public function getPorts():Array<String>
    {
        var numInputs = output.getPortCount();
        var ports = new Array<String>();
        for (i in 0...numInputs) {
            ports.push(output.getPortName(i));
        }
        return ports;
    }

    public function openPort(portNumber:Int, portName:String):Void
    {
        output.openPort(portNumber, portName);
    }

    public function openVirtualPort(portName:String):Void
    {
        output.openVirtualPort(portName);
    }

    public function closePort():Void
    {
        output.closePort();
    }

    public function isPortOpen():Bool
    {
        return output.isPortOpen();
    }

    public function sendMessage(message:MidiMessage):Void
    {
        var messageArray = new Array<Int>();
        messageArray.push(message.byte1);
        messageArray.push(message.byte2);
        messageArray.push(message.byte3);
        output.sendMessage(messageArray);
    }
}
