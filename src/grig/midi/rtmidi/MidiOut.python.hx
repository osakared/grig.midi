package grig.midi.rtmidi; #if python

import python.Exceptions;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:pythonImport('rtmidi', 'MidiOut')
@:native('MidiOut')
extern class NativeMidiOut
{
    public function new();
    public function get_ports():Array<String>;
    public function open_port(portNumber:Int, portName:String):Void;
    public function open_virtual_port(portName:String):Void;
    public function close_port():Void;
    public function is_port_open():Bool;
    public function send_message(message:Array<Int>):Void;
}

class MidiOut
{
    private var midiOut:NativeMidiOut;

    public function new()
    {
        try {
            midiOut = new NativeMidiOut();
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure while initializing MidiOut');
        }
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
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
        try {
            midiOut.close_port();
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on close_port');
        }
    }

    public function isPortOpen():Bool
    {
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
            var messageArray = new Array<Int>();
            messageArray.push(message.byte1);
            messageArray.push(message.byte2);
            messageArray.push(message.byte3);
            midiOut.send_message(messageArray);
        }
        catch (exception:BaseException) {
            throw new Error(InternalError, 'Failure on send_message');
        }
    }
}

#end