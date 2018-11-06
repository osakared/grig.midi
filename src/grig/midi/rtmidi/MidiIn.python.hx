package grig.midi.rtmidi;

import python.Tuple;

@:pythonImport('rtmidi', 'MidiIn')
@:native('MidiIn')
extern class NativeMidiIn
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

class MidiIn
{
    private var midiIn:NativeMidiIn;

    public function new()
    {
        midiIn = new NativeMidiIn();
    }

    public function getPorts():Array<String>
    {
        return midiIn.get_ports();
    }

    public function openPort(portNumber:Int, portName:String):Void
    {
        midiIn.open_port(portNumber, portName);
    }

    public function openVirtualPort(portName:String):Void
    {
        midiIn.open_virtual_port(portName);
    }

    public function closePort():Void
    {
        midiIn.close_port();
    }

    public function isPortOpen():Bool
    {
        return midiIn.is_port_open();
    }

    public function setCallback(callback:(MidiMessage, Float)->Void):Void
    {
        midiIn.set_callback(function (message:Tuple2<Array<Int>, Float>, data:Dynamic) {
            callback(MidiMessage.fromArray(message._1), message._2);
        });
    }

    public function cancelCallback():Void
    {
        midiIn.cancel_callback();
    }
}
