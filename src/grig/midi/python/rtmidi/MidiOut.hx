package grig.midi.python.rtmidi; #if python

import grig.midi.Api;
import python.Exceptions;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:pythonImport('rtmidi', 'MidiOut')
@:native('MidiOut')
extern class NativeMidiOut
{
    public function new(api:Api);
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function send_message(message:Array<Int>):Void;
}

class MidiOut implements MidiSender
{
    private var api:Api;
    private var midiOut:NativeMidiOut = null;

    private function instantiateMidiOut():Void
    {
        midiOut = new NativeMidiOut(api);
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
                instantiateMidiOut();
                _callback(Success(midiOut.get_ports()));
            }
            catch (exception:BaseException) {
                _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports.')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                instantiateMidiOut();
                midiOut.open_port(portNumber, portName);
                _callback(Success(this));
            }
            catch (exception:BaseException) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber')));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                instantiateMidiOut();
                midiOut.open_virtual_port(portName);
                _callback(Success(this));
            }
            catch (exception:BaseException) {
                _callback(Failure(new Error(InternalError, 'Failed to open virtual midi port')));
            }
        });
    }

    public function closePort():Void
    {
        if (midiOut == null) return;
        try {
            midiOut.close_port();
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on close_port');
        }
    }

    public function isPortOpen():Bool
    {
        if (midiOut == null) return false;
        try {
            return midiOut.is_port_open();
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on is_port_open');
        }
    }

    public function sendMessage(message:MidiMessage):Void
    {
        try {
            midiOut.send_message(message.toArray());
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on send_message');
        }
    }
}

#end