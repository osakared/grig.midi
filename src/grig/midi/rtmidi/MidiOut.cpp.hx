package grig.midi.rtmidi; #if cpp

import cpp.Char;
import cpp.ConstPointer;
import cpp.RawPointer;
import cpp.Pointer;
import cpp.StdString;
import cpp.StdStringRef;
import cpp.UInt8;
import cpp.vm.Gc;

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:build(grig.midi.rtmidi.Build.xml())
@:include('./rtmidi/rtmidi_c.h')

typedef RtMidiOutPtr = Pointer<RtMidiWrapper>;
typedef RtMidiMessage = cpp.RawConstPointer<cpp.UInt8>;

extern class RtMidiOut
{
    @:native("rtmidi_out_create_default")
    static public function create():RtMidiOutPtr;
    @:native("rtmidi_out_free")
    static public function destroy(rtmidiptr:RtMidiOutPtr):Void;
    @:native("rtmidi_get_port_count")
    static public function getPortCount(rtmidiptr:RtMidiOutPtr):Int;
    @:native("rtmidi_get_port_name")
    static public function getPortName(rtmidiptr:RtMidiOutPtr, index:Int):StdStringRef;
    @:native("rtmidi_open_port")
    static public function openPort(rtmidiptr:RtMidiOutPtr, portNumber:Int, portName:ConstPointer<Char>):Void;
    @:native("rtmidi_open_virtual_port")
    static public function openVirtualPort(rtmidiptr:RtMidiOutPtr, portName:ConstPointer<Char>):Void;
    @:native("rtmidi_close_port")
    static public function closePort(rtmidiptr:RtMidiOutPtr):Void;
    @:native("rtmidi_out_send_message")
    static public function sendMessage(rtmidiptr:RtMidiOutPtr, message:RtMidiMessage, length:cpp.UInt64):Void;
}

class MidiOut
{
    private var output:RtMidiOutPtr;
    private var connected:Bool = false;

    private function checkError():Void
    {
        if (output.ptr.ok == true) return;
        var message:StdStringRef = output.ptr.msg;
        throw new Error(InternalError, message.toString());
    }

    private static function onDestruct(midiOut:MidiOut)
    {
        RtMidiOut.destroy(midiOut.output);
    }

    public function new()
    {
        output = RtMidiOut.create();
        Gc.setFinalizer(this, cpp.Function.fromStaticFunction(onDestruct));
        checkError();
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                var numOutputs = RtMidiOut.getPortCount(output);
                checkError();
                var ports = new Array<String>();
                for (i in 0...numOutputs) {
                    var portName:StdStringRef = RtMidiOut.getPortName(output, i);
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

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                RtMidiOut.openPort(output, portNumber, StdString.ofString(portName).c_str());
                checkError();
                connected = true;
                _callback(Success(this));
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber. $error.message')));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                RtMidiOut.openVirtualPort(output, StdString.ofString(portName).c_str());
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
        RtMidiOut.closePort(output);
        connected = false;
        checkError();
    }

    public function isPortOpen():Bool
    {
        return connected;
    }

    public function sendMessage(message:MidiMessage):Void
    {
        var inArray = message.toArray();
        var outLength = inArray.length;
        var outArray:cpp.RawPointer<cpp.UInt8> = untyped __cpp__('new unsigned char[outLength]');
        for (i in 0...outLength) {
            outArray[i] = inArray[i];
        }
        RtMidiOut.sendMessage(output, outArray, outLength);
        untyped __cpp__('delete[] outArray');
        checkError();
    }
}

#end