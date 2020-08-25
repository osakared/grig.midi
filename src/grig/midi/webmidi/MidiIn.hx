package grig.midi.webmidi;  #if (js && !nodejs)

import js.html.midi.*;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiIn
{
    private var midiAccess:MIDIAccess;
    private var midiPort:MIDIPort;
    private var callback:(MidiMessage, Float)->Void;
    private var lastTime:Float = 0;

    private function handleMidiEvent(midiMessageEvent:MIDIMessageEvent)
    {
        if (callback != null) {
            callback(MidiMessage.fromArray([midiMessageEvent.data[0], midiMessageEvent.data[1], midiMessageEvent.data[2]]), midiMessageEvent.timeStamp - lastTime);
            lastTime = midiMessageEvent.timeStamp;
        }
    }

    public function new(api:grig.midi.Api = grig.midi.Api.Unspecified)
    {
        if (api != grig.midi.Api.Unspecified && api != grig.midi.Api.Browser) {
            throw new Error(InternalError, 'In webmidi, only "Browser" api supported');
        }
    }

    public static function getApis():Array<Api>
    {
        return [grig.midi.Api.Browser];
    }

    public function getPorts():Surprise<Array<String>, Error>
    {
        if (js.Browser.navigator.requestMIDIAccess == null) {
            return Future.sync(Failure(new Error(InternalError, 'Webmidi not available')));
        }
        return Future.async(function(_callback) {
            js.Browser.navigator.requestMIDIAccess({}).then(function(_midiAccess:MIDIAccess) {
                midiAccess = _midiAccess;
                var ports = new Array<String>();
                midiAccess.inputs.forEach(function(value:MIDIInput, key:String, map) {
                    ports.push(value.name);
                });
                _callback(Success(ports));
            }).catchError(function(e:js.lib.Error) {
                _callback(Failure(Error.withData(e.message, e)));
            });
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, Error>
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
                    value.open().then(function(_midiPort:MIDIPort) {
                        midiPort = _midiPort;
                        _callback(Success(this));
                    });
                    i = -1;
                    return;
                }
                i++;
            });
            if (i != -1) _callback(Failure(new Error(InternalError, 'Port number out of range: $portNumber')));
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, Error>
    {
        return Future.async(function(_callback) {
            _callback(Failure(new Error(InternalError, 'Virtual ports not supported')));
        });
    }

    public function closePort():Void
    {
        if (midiPort != null) {
            midiPort.close().then(function(_midiPort:MIDIPort) {
                midiPort = null;
            });
        }
    }

    public function isPortOpen():Bool
    {
        return (midiPort != null && midiPort.state == CONNECTED);
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