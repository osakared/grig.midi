package grig.midi.rtmidi; #if nodejs

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:jsRequire('midi','output')
extern class NativeMidiOut
{
    public function new();
    public function getPortCount():Int;
    public function getPortName(index:Int):String;
    public function openPort(portNumber:Int, portName:String):Void;
    public function openVirtualPort(portName:String):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function sendMessage(message:Array<Int>):Void;
}

class MidiOut
{
    private var output:NativeMidiOut;

    public function new()
    {
        try {
            output = new NativeMidiOut();
        }
        catch (error:js.Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function getApis():Array<Api>
    {
        var apis = new Array<Api>();

        // not implemented BOOOO!

        return apis;
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                var numInputs = output.getPortCount();
                var ports = new Array<String>();
                for (i in 0...numInputs) {
                    ports.push(output.getPortName(i));
                }
                _callback(Success(ports));
            }
            catch (error:js.Error) {
                _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports. $error.message')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                output.openPort(portNumber, portName);
                _callback(Success(this));
            }
            catch (error:js.Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber. $error')));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async(function(_callback) { 
            try {
                output.openVirtualPort(portName);
                _callback(Success(this));
            }
            catch (exception:js.Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open virtual midi port')));
            }
        });
    }

    public function closePort():Void
    {
        try {
            output.closePort();
        }
        catch (error:js.Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function isPortOpen():Bool
    {
        try {
            return output.isPortOpen();
        }
        catch (error:js.Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function sendMessage(message:MidiMessage):Void
    {
        try {
            var messageArray = new Array<Int>();
            messageArray.push(message.byte1);
            messageArray.push(message.byte2);
            messageArray.push(message.byte3);
            output.sendMessage(messageArray);
        }
        catch(error:js.Error) {
            throw new Error(InternalError, error.message);
        }
    }
}

#end