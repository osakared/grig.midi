package grig.midi.python.rtmidi; #if python

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
    public function new(api:Api);
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function set_callback(callback:(midiMessage:Tuple2<Array<Int>, Float>, data:Dynamic)->Void, data:Dynamic = null):Void;
    public function cancel_callback():Void;
}

class MidiIn extends grig.midi.MidiInBase
{
    private var api:Api;
    private var midiIn:NativeMidiIn = null;

    private function handleMidiEvent(message:Tuple2<Array<Int>, Float>, data:Dynamic)
    {
        if (callback == null) return;
        callback(MidiMessage.ofArray(message._1), message._2);
    }

    private function intantiateMidiIn():Void
    {
        if (midiIn != null) return;
        midiIn = new NativeMidiIn(api);
        midiIn.set_callback(handleMidiEvent);
    }
 
    public function new(api:Api = Api.Unspecified)
    {
        this.api = api;
    }

    public static function getApis():Array<Api>
    {
        return RtMidi.get_compiled_api();
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                intantiateMidiIn();
                _callback(Success(midiIn.get_ports()));
            }
            catch (exception:BaseException) {
                _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                intantiateMidiIn();
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
                intantiateMidiIn();
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
        if (midiIn == null) return;
        try {
            midiIn.close_port();
        }
        catch (exception:BaseException) {
            trace('Failure on close_port');
        }
    }

    public function isPortOpen():Bool
    {
        if (midiIn == null) return false;
        try {
            return midiIn.is_port_open();
        }
        catch (exception:BaseException) {
            trace('Failure on is_port_open');
            return false;
        }
    }
}

#end