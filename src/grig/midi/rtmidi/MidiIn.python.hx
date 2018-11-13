package grig.midi.rtmidi;

import python.Exceptions;
import python.Tuple;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

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
    private var callback:(MidiMessage, Float)->Void;

    private function handleMidiEvent(message:Tuple2<Array<Int>, Float>, data:Dynamic)
    {
        if (callback != null) {
            callback(MidiMessage.fromArray(message._1), message._2);
        }
    }
 
    public function new()
    {
        midiIn = new NativeMidiIn();
        midiIn.set_callback(handleMidiEvent);
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        try {
            return Future.sync(Success(midiIn.get_ports()));
        }
        catch (exception:BaseException) {
            return Future.sync(Failure(new Error(InternalError, 'Failure while fetching list of midi ports')));
        }
    }

    public function openPort(portNumber:Int, portName:String):Surprise<Bool, tink.core.Error>
    {
        try {
            midiIn.open_port(portNumber, portName);
            return Future.sync(Success(true));
        }
        catch (exception:BaseException) {
            return Future.sync(Failure(new Error(InternalError, 'Failed to open port $portNumber')));
        }
    }

    public function openVirtualPort(portName:String):Surprise<Bool, tink.core.Error>
    {
        try {
            midiIn.open_virtual_port(portName);
            return Future.sync(Success(true));
        }
        catch (exception:BaseException) {
            return Failure(new Error(InternalError, 'Failed to open virtual midi port'));
        }
    }

    public function closePort():Void
    {
        midiIn.close_port();
    }

    public function isPortOpen():Bool
    {
        return midiIn.is_port_open();
    }

    public function setCallback(_callback:(MidiMessage, Float)->Void):Void
    {
        callback = _callback;
    }

    public function cancelCallback():Void
    {
        callback = null;
    }
}
