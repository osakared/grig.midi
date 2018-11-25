package grig.midi.rtmidi; #if cpp

import cpp.RawPointer;
import cpp.StdString;
import cpp.StdStringRef;
import cpp.UInt8;

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:structAccess
@:native('std::vector<unsigned char>')
extern class UInt8Vector {
    @:native('std::vector<unsigned char>') public static function create():UInt8Vector;
    @:native('push_back') public function pushBack(value:UInt8):Void;
    public function at(index:Int):UInt8;
}

@:build(grig.midi.rtmidi.Build.xml())
@:include('./rtmidi/RtMidi.h')
@:native('::RtMidiIn')
@:structAccess
extern class RtMidiIn
{
    @:native("RtMidiIn")
    static public function create():RtMidiIn;
    public function getPortCount():Int;
    public function getPortName(index:Int):StdString;
    public function openPort(portNumber:Int, portName:StdStringRef):Void;
    public function openVirtualPort(portName:StdStringRef):Void;
    public function closePort():Void;
    public function isPortOpen():Bool;
    public function setCallback(callback:cpp.Callable<(delta:Float, message:RawPointer<UInt8Vector>, userData:RawPointer<cpp.Void>)->Void>):Void;
    public function cancelCallback():Void;
}

class MidiIn
{
    private var input:RtMidiIn;
    private var callback:(MidiMessage, Float)->Void;

    private static function handleMidiEvent(delta:Float, message:RawPointer<UInt8Vector>, userData:RawPointer<cpp.Void>)
    {

    }

    // private function handleMidiEvent(delta:Float, message:Array<Int>, userData:cpp.Pointer<cpp.Void>)
    // {
    //     if (callback != null) callback(MidiMessage.fromArray(message), delta);
    // }

    public function new()
    {
        try {
            trace('creating RtMidiIn');
            input = RtMidiIn.create();
            trace('setting callback');
            input.setCallback(cpp.Function.fromStaticFunction(handleMidiEvent));
        }
        catch (error:Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                trace('getting num inputs');
                var numInputs = input.getPortCount();
                trace('numInputs: $numInputs');
                var ports = new Array<String>();
                for (i in 0...numInputs) {
                    var portName:StdStringRef = input.getPortName(i);
                    ports.push(portName.toString());
                }
                _callback(Success(ports));
            }
            catch (exception:Error) {
                _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                input.openPort(portNumber, StdString.ofString(portName));
                _callback(Success(this));
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber. $error.message' )));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                input.openVirtualPort(StdString.ofString(portName));
                _callback(Success(this));
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open virtual midi port: $error.message')));
            }
        });
    }

    public function closePort():Void
    {
        try {
            input.closePort();
        }
        catch (error:Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function isPortOpen():Bool
    {
        try {
            return input.isPortOpen();
        }
        catch (error:Error) {
            throw new Error(InternalError, error.message);
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