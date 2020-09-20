package grig.midi.cpp.rtmidi; #if cpp

// import cpp.Char;
// import cpp.ConstPointer;
// import cpp.RawPointer;
import cpp.Pointer;
// import cpp.StdString;
// import cpp.StdStringRef;
// import cpp.UInt8;
import cpp.vm.Gc;

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:build(grig.midi.cpp.rtmidi.Build.xml())

@:native('RtMidiOut')
@:structAccess
extern class RtMidiOut
{
    public function isPortOpen():Bool;
    public function closePort():Void;
}

typedef RtMidiOutPtr = Pointer<RtMidiOut>;

extern class RtMidiOutWrapper
{
    @:native("grig::rtmidi_out_create")
    static public function create(api:grig.midi.Api, errors:Array<String>):RtMidiOutPtr;
    @:native("grig::rtmidi_out_destroy")
    static public function destroy(rtMidiOut:RtMidiOutPtr):Void;
    @:native("grig::rtmidi_get_compiled_api")
    static public function getCompiledApi():Array<grig.midi.Api>;
    @:native("grig::rtmidi_out_get_port_names")
    static public function getPortNames(rtMidiOut:RtMidiOutPtr, errors:Array<String>):Array<String>;
    @:native("grig::rtmidi_out_open_port")
    static public function openPort(rtMidiOut:RtMidiOutPtr, port:Int, portName:String, errors:Array<String>):Void;
    @:native("grig::rtmidi_out_open_virtual_port")
    static public function openVirtualPort(rtMidiOut:RtMidiOutPtr, portName:String, errors:Array<String>):Void;
    @:native("grig::rtmidi_out_send_message")
    static public function sendMessage(rtMidiOut:RtMidiOutPtr, message:Array<cpp.UInt8>, errors:Array<String>):Void;
}

@:headerInclude('./rtmidi.h')
class MidiOut implements grig.midi.MidiSender
{
    private var api:grig.midi.Api;
    private var rtMidiOut:RtMidiOutPtr = null;
    private var errors = new Array<String>();

    private function checkError(errorTitle:String, errorCallback:(error:Error)->Void):Void
    {
        if (rtMidiOut == null) {
            var errorMessage = errors.join('\n\t');
            errors.resize(0);
            errorCallback(new Error(InternalError, '$errorTitle $errorMessage'));
        }
    }

    private function instantiateRtMidiOut(errorCallback:(error:Error)->Void):Void
    {
        if (rtMidiOut != null) return;
        rtMidiOut = RtMidiOutWrapper.create(api, errors);
        checkError('RtMidi instantiation error:', errorCallback);
    }

    private static function onDestruct(midiOut:MidiOut)
    {
        RtMidiOutWrapper.destroy(midiOut.rtMidiOut);
    }

    public function new(api:grig.midi.Api)
    {
        this.api = api;
        Gc.setFinalizer(this, cpp.Function.fromStaticFunction(onDestruct));
    }

    public static function getApis():Array<Api>
    {
        return RtMidiOutWrapper.getCompiledApi();
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        return Future.async((callback) -> {
            instantiateRtMidiOut((error) -> {
                callback(Failure(error));
            });
            var portNames = RtMidiOutWrapper.getPortNames(rtMidiOut, errors);
            checkError('Get port names error:', (error) -> {
                callback(Failure(error));
            });
            callback(Success(portNames));
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async((callback) -> {
            instantiateRtMidiOut((error) -> {
                callback(Failure(error));
            });
            RtMidiOutWrapper.openPort(rtMidiOut, portNumber, portName, errors);
            checkError('Error opening port:', (error) -> {
                callback(Failure(error));
            });
            callback(Success(this));
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>
    {
        return Future.async((callback) -> {
            instantiateRtMidiOut((error) -> {
                callback(Failure(error));
            });
            RtMidiOutWrapper.openVirtualPort(rtMidiOut, portName, errors);
            checkError('Error opening port:', (error) -> {
                callback(Failure(error));
            });
            callback(Success(this));
        });
    }

    public function closePort():Void
    {
        if (rtMidiOut != null) rtMidiOut.ref.closePort();
    }

    public function isPortOpen():Bool
    {
        if (rtMidiOut != null) return rtMidiOut.ref.isPortOpen();
        return false;
    }

    public function sendMessage(message:MidiMessage):Void
    {
        if (rtMidiOut == null) return;
        RtMidiOutWrapper.sendMessage(rtMidiOut, message.getData(), errors);
        for (error in errors) {
            trace('Midi send message error: $error');
        }
        errors.resize(0);
    }
}

// typedef RtMidiOutPtr = Pointer<RtMidiWrapper>;
// typedef RtMidiMessage = cpp.RawConstPointer<UInt8>;

// @:native('RtMidiApi')
// extern class RtMidiApi
// {
// }

// extern class RtMidiOut
// {
//     @:native("rtmidi_out_create")
//     static public function create(api:RtMidiApi, clientName:ConstPointer<Char>):RtMidiOutPtr;
//     @:native("rtmidi_get_compiled_api")
//     static public function getCompiledApi(apis:RawPointer<RtMidiApi>, apisSize:Int):Int;
//     @:native("rtmidi_out_free")
//     static public function destroy(rtmidiptr:RtMidiOutPtr):Void;
//     @:native("rtmidi_get_port_count")
//     static public function getPortCount(rtmidiptr:RtMidiOutPtr):Int;
//     @:native("rtmidi_get_port_name")
//     static public function getPortName(rtmidiptr:RtMidiOutPtr, index:Int):StdStringRef;
//     @:native("rtmidi_open_port")
//     static public function openPort(rtmidiptr:RtMidiOutPtr, portNumber:Int, portName:ConstPointer<Char>):Void;
//     @:native("rtmidi_open_virtual_port")
//     static public function openVirtualPort(rtmidiptr:RtMidiOutPtr, portName:ConstPointer<Char>):Void;
//     @:native("rtmidi_close_port")
//     static public function closePort(rtmidiptr:RtMidiOutPtr):Void;
//     @:native("rtmidi_out_send_message")
//     static public function sendMessage(rtmidiptr:RtMidiOutPtr, message:RtMidiMessage, length:cpp.UInt64):Void;
// }

// class MidiOut
// {
//     private var output:RtMidiOutPtr;
//     private var connected:Bool = false;

//     private function checkError():Void
//     {
//         if (output.ptr.ok == true) return;
//         var message:StdStringRef = output.ptr.msg;
//         throw new Error(InternalError, message.toString());
//     }

//     private static function onDestruct(midiOut:MidiOut)
//     {
//         RtMidiOut.destroy(midiOut.output);
//     }

//     public function new(api:Api = Api.Unspecified)
//     {
//         var apiIndex = api.getIndex();
//         var apiEnum = untyped __cpp__('(RtMidiApi)apiIndex');
//         output = RtMidiOut.create(apiEnum, StdString.ofString('grig RtMidi client').c_str());
//         Gc.setFinalizer(this, cpp.Function.fromStaticFunction(onDestruct));
//         checkError();
//     }

//     public static function getApis():Array<Api>
//     {
//         var apis = new Array<Api>();

//         var len = RtMidiOut.getCompiledApi(null, 0);
//         var apisList:RawPointer<RtMidiApi> = untyped __cpp__('new RtMidiApi[len]');
//         RtMidiOut.getCompiledApi(apisList, len);
//         for (i in 0...len) {
//             var api:Int = untyped __cpp__('(int)apisList[i]');
//             apis.push(Api.createByIndex(api));
//         }
//         untyped __cpp__('delete[] apisList');

//         return apis;
//     }

//     public function getPorts():Surprise<Array<String>, tink.core.Error>
//     {
//         return Future.async(function(_callback) {
//             try {
//                 var numOutputs = RtMidiOut.getPortCount(output);
//                 checkError();
//                 var ports = new Array<String>();
//                 for (i in 0...numOutputs) {
//                     var portName:StdStringRef = RtMidiOut.getPortName(output, i);
//                     checkError();
//                     ports.push(portName.toString());
//                 }
//                 _callback(Success(ports));
//             }
//             catch (error:Error) {
//                 _callback(Failure(new Error(InternalError, 'Failure while fetching list of midi ports. $error.message')));
//             }
//         });
//     }

//     public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, tink.core.Error>
//     {
//         return Future.async(function(_callback) {
//             try {
//                 RtMidiOut.openPort(output, portNumber, StdString.ofString(portName).c_str());
//                 checkError();
//                 connected = true;
//                 _callback(Success(this));
//             }
//             catch (error:Error) {
//                 _callback(Failure(new Error(InternalError, 'Failed to open port $portNumber. $error.message')));
//             }
//         });
//     }

//     public function openVirtualPort(portName:String):Surprise<MidiOut, tink.core.Error>
//     {
//         return Future.async(function(_callback) {
//             try {
//                 RtMidiOut.openVirtualPort(output, StdString.ofString(portName).c_str());
//                 checkError();
//                 connected = true;
//                 _callback(Success(this));
//             }
//             catch (error:Error) {
//                 _callback(Failure(new Error(InternalError, 'Failed to open virtual midi port: $error.message')));
//             }
//         });
//     }

//     public function closePort():Void
//     {
//         RtMidiOut.closePort(output);
//         connected = false;
//         checkError();
//     }

//     public function isPortOpen():Bool
//     {
//         return connected;
//     }

//     public function sendMessage(message:MidiMessage):Void
//     {
//         var inArray = message.toArray();
//         var outLength = inArray.length;
//         var outArray:cpp.RawPointer<cpp.UInt8> = untyped __cpp__('new unsigned char[outLength]'); // Might be good to have Gc do this instead?
//         for (i in 0...outLength) {
//             outArray[i] = inArray[i];
//         }
//         RtMidiOut.sendMessage(output, outArray, outLength);
//         untyped __cpp__('delete[] outArray');
//         checkError();
//     }
// }

#end