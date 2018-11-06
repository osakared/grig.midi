package grig.midi.rtmidi;

@:jsRequire('midi','input')
extern class NativeMidiIn
{
    public function new();
    public function getPortCount():Int;
    public function getPortName(index:Int):String;
    public function openPort(portNumber:Int, portName:String):Void;
    public function openVirtualPort(portName:String):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function on(signal:String, callback:(Float, Array<Int>)->Void):Void;
    public function cancelCallback():Void;
}

class MidiIn
{
    private var input:NativeMidiIn;

    public function new()
    {
        input = new NativeMidiIn();
    }

    public function getPorts():Array<String>
    {
        var numInputs = input.getPortCount();
        var ports = new Array<String>();
        for (i in 0...numInputs) {
            ports.push(input.getPortName(i));
        }
        return ports;
    }

    public function openPort(portNumber:Int, portName:String):Void
    {
        input.openPort(portNumber, portName);
    }

    public function openVirtualPort(portName:String):Void
    {
        input.openVirtualPort(portName);
    }

    public function closePort():Void
    {
        input.closePort();
    }

    public function isPortOpen():Bool
    {
        return input.isPortOpen();
    }

    public function setCallback(callback:(MidiMessage, Float)->Void):Void
    {
        trace('setting callback');
        input.on('message', function(delta:Float, message:Array<Int>) {
            trace(delta);
            callback(MidiMessage.fromArray(message), delta);
        });
    }

    public function cancelCallback():Void
    {
        input.cancelCallback();
    }
}
