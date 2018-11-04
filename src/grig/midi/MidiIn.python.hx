package grig.midi;

import python.Tuple;

class MidiIn
{
    private var midiIn:grig.midi.rtmidi.MidiIn;

    public function new()
    {
        midiIn = new grig.midi.rtmidi.MidiIn();
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