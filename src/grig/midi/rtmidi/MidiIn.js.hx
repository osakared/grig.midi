package grig.midi.rtmidi;

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

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
    private var callback:(MidiMessage, Float)->Void;

    private function handleMidiEvent(delta:Float, message:Array<Int>)
    {
        if (callback != null) callback(MidiMessage.fromArray(message), delta);
    }

    public function new()
    {
        input = new NativeMidiIn();
        input.on('message', handleMidiEvent);
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        try {
            var numInputs = input.getPortCount();
            var ports = new Array<String>();
            for (i in 0...numInputs) {
                ports.push(input.getPortName(i));
            }
            return Future.sync(Success(ports));
        }
        catch (exception:Dynamic) {
            return Future.sync(Failure(new Error(InternalError, 'Failure while fetching list of midi ports')));
        }
    }

    public function openPort(portNumber:Int, portName:String):Surprise<Bool, tink.core.Error>
    {
        try {
            input.openPort(portNumber, portName);
            return Future.sync(Success(true));
        }
        catch (exception:Dynamic) {
            return Future.sync(Failure(new Error(InternalError, 'Failed to open port $portNumber')));
        }
    }

    public function openVirtualPort(portName:String):Surprise<Bool, tink.core.Error>
    {
        try {
            input.openVirtualPort(portName);
            return Future.sync(Success(true));
        }
        catch (exception:Dynamic) {
            return Failure(new Error(InternalError, 'Failed to open virtual midi port'));
        }
    }

    public function closePort():Void
    {
        input.closePort();
    }

    public function isPortOpen():Bool
    {
        return input.isPortOpen();
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
