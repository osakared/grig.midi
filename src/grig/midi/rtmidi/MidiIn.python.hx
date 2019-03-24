package grig.midi.rtmidi; #if python

import grig.midi.Api;
import python.Exceptions;
import python.Tuple;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

using haxe.EnumTools;

@:pythonImport('rtmidi', 'MidiIn')
@:native('MidiIn')
extern class NativeMidiIn
{
    public function new(api:Int);
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function set_callback(callback:(midiMessage:Tuple2<Array<Int>, Float>, data:Dynamic)->Void, data:Dynamic = null):Void;
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
 
    public function new(api:Api = Api.Unspecified)
    {
        try {
            midiIn = new NativeMidiIn(api.getIndex());
            midiIn.set_callback(handleMidiEvent);
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure while initializing MidiIn');
        }
    }

    public static function getApis():Array<Api>
    {
        var apis = new Array<Api>();

        var apiIndices = RtMidi.get_compiled_api();
        for (i in apiIndices) {
            apis.push(Api.createByIndex(i));
        }

        return apis;
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                return _callback(Success(midiIn.get_ports()));
            }
            catch (exception:BaseException) {
                return _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                midiIn.open_port(portNumber, portName);
                _callback(Success(this));
            }
            catch (exception:BaseException) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber')));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                midiIn.open_virtual_port(portName);
                _callback(Success(this));
            }
            catch (exception:BaseException) {
                _callback(Failure(new Error(InternalError, 'Failed to open virtual midi port')));
            }
        });
    }

    public function closePort():Void
    {
        try {
            midiIn.close_port();
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on close_port');
        }
    }

    public function isPortOpen():Bool
    {
        try {
            return midiIn.is_port_open();
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on is_port_open');
        }
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

#end