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

typedef RtMidiInPtr = Pointer<RtMidiWrapper>;
typedef RtMidiCallback = cpp.Callable<(delta:cpp.Float64, message:cpp.RawConstPointer<UInt8>, messageSize:cpp.SizeT, userData:RawPointer<cpp.Void>)->Void>;

@:native('RtMidiApi')
extern class RtMidiApi
{
}

extern class RtMidiIn
{
    @:native("rtmidi_in_create")
    static public function create(api:RtMidiApi, clientName:ConstPointer<Char>, queueSizeLimit:Int):RtMidiInPtr;
    @:native("rtmidi_get_compiled_api")
    static public function getCompiledApi(apis:RawPointer<RtMidiApi>, apisSize:Int):Int;
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

    private var midiMessage = new MidiMessage(0);

    private function checkError():Void
    {
        if (input.ptr.ok == true) return;
        var message:StdStringRef = input.ptr.msg;
        throw new Error(InternalError, message.toString());
    }

    private static function handleMidiEvent(delta:cpp.Float64, message:cpp.RawConstPointer<UInt8>, messageSize:cpp.SizeT, userData:RawPointer<cpp.Void>)
    {
        var midiIn:MidiIn = untyped __cpp__('(MidiIn_obj*)userData');
        if (midiIn.callback == null) return;
        var constMessage = ConstPointer.fromRaw(message);
        midiIn.midiMessage.bytes = 0;
        for (i in 0...messageSize) {
            midiIn.midiMessage.bytes += constMessage.at(i) << (messageSize - (i + 1)) * 8;
        }
        midiIn.callback(midiIn.midiMessage, delta);
    }

    private static function onDestruct(midiIn:MidiIn)
    {
        RtMidiIn.destroy(midiIn.input);
    }

    public function new(api:Api = Api.Unspecified)
    {
        var apiIndex = api.getIndex();
        var apiEnum = untyped __cpp__('(RtMidiApi)apiIndex');
        input = RtMidiIn.create(apiEnum, StdString.ofString('grig RtMidi client').c_str(), 1024);
        Gc.setFinalizer(this, cpp.Function.fromStaticFunction(onDestruct));
        checkError();
        RtMidiIn.setCallback(input, cpp.Function.fromStaticFunction(handleMidiEvent), untyped __cpp__('(void*)this'));
        checkError();
    }

    public static function getApis():Array<Api>
    {
        var apis = new Array<Api>();

        var len = RtMidiIn.getCompiledApi(null, 0);
        var apisList:RawPointer<RtMidiApi> = untyped __cpp__('new RtMidiApi[len]');
        RtMidiIn.getCompiledApi(apisList, len);
        for (i in 0...len) {
            var api:Int = untyped __cpp__('(int)apisList[i]');
            apis.push(Api.createByIndex(api));
        }
        untyped __cpp__('delete[] apisList');

        return apis;
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
        RtMidiIn.closePort(input);
        connected = false;
        checkError();
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