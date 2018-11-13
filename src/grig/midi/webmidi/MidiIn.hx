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
            if (isPortOpen()) {
                _callback(Failure(new Error(InternalError, 'Midi port already open')));
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
                    i = -1;
                    return;
                }
                i++;
            });
            if (i != -1) _callback(Failure(new Error(InternalError, 'Port number out of range: $portNumber')));
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
        if (midiInput != null) {
            midiInput.close().then(function(_midiInput:MIDIInput) {
                midiInput = null;
            });
        }
    }

    public function isPortOpen():Bool
    {
        return (midiInput != null && midiInput.state == 'connected');
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