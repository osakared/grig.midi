package grig.midi.webmidi;

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiIn
{
    private var midiAccess:MIDIAccess;
    private var midiInput:MIDIInput;
    private var midiAccessFuture:js.Promise<Void>;
    private var ports:Array<String>;
    private var callback:(MidiMessage, Float)->Void;
    private var lastTime:Float = 0;

    private function handleMidiEvent(midiMessageEvent:MIDIMessageEvent)
    {
        if (callback != null) {
            var dataView = new js.html.DataView(midiMessageEvent.data.buffer);
            callback(MidiMessage.fromArray([midiMessageEvent.data[0], midiMessageEvent.data[1], midiMessageEvent.data[2]]), midiMessageEvent.timeStamp - lastTime);
            lastTime = midiMessageEvent.timeStamp;
        }
    }

    public function new()
    {
        ports = new Array<String>();

        var nagivator:Navigator = Browser.window.navigator;
        if (untyped __js__('navigator.requestMIDIAccess != undefined')) {
            midiAccessFuture = nagivator.requestMIDIAccess().then(function(_midiAccess:MIDIAccess) {
                midiAccess = _midiAccess;
                midiAccess.inputs.forEach(function(value:MIDIInput, key:String, map) {
                    ports.push(value.name);
                });
                midiAccessFuture = null;
            });
        }
    }

    public function getPorts():Surprise<Array<String>, Error>
    {
        if (midiAccessFuture == null) return Future.sync(Success(ports));
        return Future.async(function(_callback) {
            midiAccessFuture.then(function(_) {
                _callback(Success(ports));
            }).catchError(function(e:js.Error) {
                _callback(Failure(Error.withData(e.message, e)));
            });
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<Bool, Error>
    {
        return Future.async(function(_callback) {
            if (midiAccess == null) {
                _callback(Failure(new Error(InternalError, 'MIDIInput not available')));
                return;
            }
            var i = 0;
            midiAccess.inputs.forEach(function(value:MIDIInput, key:String, map) {
                if (i == portNumber) {
                    value.onmidimessage = handleMidiEvent;
                    value.open().then(function(_midiInput:MIDIInput) {
                        midiInput = _midiInput;
                        _callback(Success(true));
                    });
                    return;
                }
                i++;
            });
        });
    }

    public function openVirtualPort(portName:String):Surprise<Bool, Error>
    {
        return Future.async(function(_callback) {
            _callback(Failure(new Error(InternalError, 'Virtual ports not supported')));
        });
    }

    public function closePort():Void
    {

    }

    public function isPortOpen():Bool
    {
        
        return false;
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