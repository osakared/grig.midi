package grig.midi.js.rtmidi; #if nodejs

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;
import grig.midi.Api;

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

class MidiIn extends grig.midi.MidiInBase
{
    private var input:NativeMidiIn;

    private function handleMidiEvent(delta:Float, message:Array<Int>)
    {
        if (callback != null) callback(MidiMessage.ofArray(message), delta);
    }

    public function new(api:Api = Api.Unspecified)
    {
        try {
            input = new NativeMidiIn();
            input.on('message', handleMidiEvent);
        }
        catch (error:js.lib.Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public static function getApis():Array<Api>
    {
        var apis = new Array<Api>();

        // not implemented BOOOO!

        return apis;
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                var numInputs = input.getPortCount();
                var ports = new Array<String>();
                for (i in 0...numInputs) {
                    ports.push(input.getPortName(i));
                }
                _callback(Success(ports));
            }
            catch (exception:js.lib.Error) {
                _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                input.openPort(portNumber, portName);
                _callback(Success(this));
            }
            catch (error:js.lib.Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber. $error.message' )));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                input.openVirtualPort(portName);
                _callback(Success(this));
            }
            catch (error:js.lib.Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open virtual midi port: $error.message')));
            }
        });
    }

    public function closePort():Void
    {
        try {
            input.closePort();
        }
        catch (error:js.lib.Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function isPortOpen():Bool
    {
        try {
            return input.isPortOpen();
        }
        catch (error:js.lib.Error) {
            throw new Error(InternalError, error.message);
        }
    }
}

#end