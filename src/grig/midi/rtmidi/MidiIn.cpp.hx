package grig.midi.rtmidi; #if cpp

import cpp.Char;
import cpp.ConstPointer;
import cpp.RawPointer;
import cpp.Pointer;
import cpp.StdString;
import cpp.StdStringRef;
import cpp.UInt8;

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:build(grig.midi.rtmidi.Build.xml())
@:include('./rtmidi/rtmidi_c.h')

@:native('RtMidiWrapper')
@:structaccess
extern class RtMidiWrapper
{
    public var ok:Bool;
    public var msg:StdStringRef;
}

typedef RtMidiInPtr = Pointer<RtMidiWrapper>;
typedef RtMidiCallback = cpp.Callable<(delta:Float, message:cpp.RawConstPointer<cpp.UInt8>, messageSize:cpp.UInt64, userData:RawPointer<cpp.Void>)->Void>;

extern class RtMidiIn
{
    @:native("rtmidi_in_create_default")
    static public function create():RtMidiInPtr;
    @:native("rtmidi_in_free")
    static public function destroy(rtmidiptr:RtMidiInPtr):Void; // okay, but when do I call this?
    @:native("rtmidi_get_port_count")
    static public function getPortCount(rtmidiptr:RtMidiInPtr):Int;
    @:native("rtmidi_get_port_name")
    static public function getPortName(rtmidiptr:RtMidiInPtr, index:Int):StdStringRef;
    @:native("rtmidi_open_port")
    static public function openPort(rtmidiptr:RtMidiInPtr, portNumber:Int, portName:ConstPointer<Char>):Void;
    @:native("rtmidi_open_virtual_port")
    static public function openVirtualPort(rtmidiptr:RtMidiInPtr, portName:ConstPointer<Char>):Void;
    @:native("rtmidi_close_port")
    static public function closePort(rtmidiptr:RtMidiInPtr):Void;
    @:native("rtmidi_in_set_callback")
    static public function setCallback(rtmidiptr:RtMidiInPtr, callback:RtMidiCallback, userData:Dynamic):Void;
    @:native("rtmidi_in_cancel_callback")
    static public function cancelCallback(rtmidiptr:RtMidiInPtr):Void;
}

class MidiIn
{
    private var input:RtMidiInPtr;
    private var connected:Bool = false;
    private var callback:(MidiMessage, Float)->Void;

    private function checkError():Void
    {
        if (input.ptr.ok == true) return;
        var message:StdStringRef = input.ptr.msg;
        throw new Error(InternalError, message.toString());
    }

    private static function handleMidiEvent(delta:Float, message:cpp.RawConstPointer<cpp.UInt8>, messageSize:cpp.UInt64, userData:RawPointer<cpp.Void>)
    {
        var constMessage = ConstPointer.fromRaw(message);
        var messageArray = new Array<Int>();
        for (i in 0...messageSize) {
            messageArray.push(constMessage.at(i));
        }
        var midiIn:MidiIn = untyped __cpp__('(MidiIn_obj*)userData');
        if (midiIn.callback != null) midiIn.callback(MidiMessage.fromArray(messageArray), delta);
    }

    public function new()
    {
        input = RtMidiIn.create();
        checkError();
        RtMidiIn.setCallback(input, cpp.Function.fromStaticFunction(handleMidiEvent), untyped __cpp__('(void*)this'));
        checkError();
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                var numInputs = RtMidiIn.getPortCount(input);
                checkError();
                var ports = new Array<String>();
                for (i in 0...numInputs) {
                    var portName:StdStringRef = RtMidiIn.getPortName(input, i);
                    checkError();
                    ports.push(portName.toString());
                }
                _callback(Success(ports));
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports. $error.message')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                RtMidiIn.openPort(input, portNumber, StdString.ofString(portName).c_str());
                checkError();
                connected = true;
                _callback(Success(this));
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber. $error.message')));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                RtMidiIn.openVirtualPort(input, StdString.ofString(portName).c_str());
                checkError();
                connected = true;
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
            RtMidiIn.closePort(input);
            connected = false;
            checkError();
        }
        catch (error:Error) {
            throw new Error(InternalError, error.message);
        }
    }

    public function isPortOpen():Bool
    {
        return connected;
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