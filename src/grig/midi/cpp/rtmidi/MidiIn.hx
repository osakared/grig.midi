package grig.midi.cpp.rtmidi; #if cpp

import cpp.Pointer;
import cpp.vm.Gc;
import haxe.io.Bytes;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:build(grig.midi.cpp.rtmidi.Build.xml())

@:native('RtMidiIn')
@:structAccess
extern class RtMidiIn
{
    public function isPortOpen():Bool;
    public function closePort():Void;
}

typedef RtMidiInPtr = Pointer<RtMidiIn>;

extern class RtMidiInWrapper
{
    @:native("grig::rtmidi_in_create")
    static public function create(api:grig.midi.Api, errors:Array<String>):RtMidiInPtr;
    @:native("grig::rtmidi_in_destroy")
    static public function destroy(rtMidiIn:RtMidiInPtr):Void;
    @:native("grig::rtmidi_get_compiled_api")
    static public function getCompiledApi():Array<grig.midi.Api>;
    @:native("grig::rtmidi_in_get_port_names")
    static public function getPortNames(rtMidiIn:RtMidiInPtr, errors:Array<String>):Array<String>;
    @:native("grig::rtmidi_in_open_port")
    static public function openPort(rtMidiIn:RtMidiInPtr, port:Int, portName:String, errors:Array<String>):Void;
    @:native("grig::rtmidi_in_open_virtual_port")
    static public function openVirtualPort(rtMidiIn:RtMidiInPtr, portName:String, errors:Array<String>):Void;
    @:native("grig::rtmidi_in_set_callback")
    static public function setCallback(rtMidiIn:RtMidiInPtr, midiIn:MidiIn):Void;
}

@:headerInclude('./rtmidi_in.h')
@:cppInclude('./rtmidi_in.cc')
class MidiIn extends grig.midi.MidiInBase
{
    private var api:grig.midi.Api;
    private var errors = new Array<String>();
    private var rtMidiIn:RtMidiInPtr = null;

    private function midiCallback(delta:Float, message:Array<cpp.UInt8>):Void
    {
        if (callback == null) return;
        var midiMessage = new MidiMessage(Bytes.ofData(message));
        callback(midiMessage, delta);
    }

    private function checkError(errorTitle:String, errorCallback:(error:Error)->Void):Void
    {
        if (rtMidiIn == null) {
            var errorMessage = errors.join('\n\t');
            errors.resize(0);
            errorCallback(new Error(InternalError, '$errorTitle $errorMessage'));
        }
    }

    private function instantiateRtMidiIn(errorCallback:(error:Error)->Void):Void
    {
        if (rtMidiIn != null) return;
        rtMidiIn = RtMidiInWrapper.create(api, errors);
        checkError('RtMidi instantiation error:', errorCallback);
        if (rtMidiIn != null) {
            RtMidiInWrapper.setCallback(rtMidiIn, this);
        }
    }

    private static function onDestruct(midiIn:MidiIn)
    {
        RtMidiInWrapper.destroy(midiIn.rtMidiIn);
    }

    public function new(api:grig.midi.Api)
    {
        this.api = api;
        Gc.setFinalizer(this, cpp.Function.fromStaticFunction(onDestruct));
    }

    public static function getApis():Array<grig.midi.Api>
    {
        return RtMidiInWrapper.getCompiledApi();
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async((callback) -> {
            instantiateRtMidiIn((error) -> {
                callback(Failure(error));
            });
            if (rtMidiIn == null) return;
            var portNames = RtMidiInWrapper.getPortNames(rtMidiIn, errors);
            checkError('Get port names error:', (error) -> {
                callback(Failure(error));
            });
            callback(Success(portNames));
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async((callback) -> {
            instantiateRtMidiIn((error) -> {
                callback(Failure(error));
            });
            if (rtMidiIn == null) return;
            RtMidiInWrapper.openPort(rtMidiIn, portNumber, portName, errors);
            checkError('Error opening port:', (error) -> {
                callback(Failure(error));
            });
            callback(Success(this));
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async((callback) -> {
            instantiateRtMidiIn((error) -> {
                callback(Failure(error));
            });
            if (rtMidiIn == null) return;
            RtMidiInWrapper.openVirtualPort(rtMidiIn, portName, errors);
            checkError('Error opening virtual port:', (error) -> {
                callback(Failure(error));
            });
            callback(Failure(new Error(InternalError, 'Not implemented yet')));
        });
    }

    public function closePort():Void
    {
        if (rtMidiIn != null) rtMidiIn.ref.closePort();
    }

    public function isPortOpen():Bool
    {
        if (rtMidiIn == null) return false;
        return rtMidiIn.ref.isPortOpen();
    }
}

#end