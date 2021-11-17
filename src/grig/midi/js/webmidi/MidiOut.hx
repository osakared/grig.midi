package grig.midi.js.webmidi; #if (js && !nodejs)

import js.html.midi.*;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiOut implements MidiSender
{
    private var midiAccess:MIDIAccess;
    private var midiOutput:MIDIOutput;

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
        return Future.async((callback) -> {
            js.Browser.navigator.requestMIDIAccess({}).then((_midiAccess:MIDIAccess) -> {
                midiAccess = _midiAccess;
                var ports = new Array<String>();
                midiAccess.inputs.forEach((value:MIDIInput, key:String, map) -> {
                    ports.push(value.name);
                });
                callback(Success(ports));
            }).catchError((e:js.lib.Error) -> {
                callback(Failure(Error.withData(e.message, e)));
            });
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, Error>
    {
        return Future.async((callback) -> {
            if (midiAccess == null) {
                callback(Failure(new Error(InternalError, 'MIDIOutput not available')));
                return;
            }
            if (isPortOpen()) {
                callback(Failure(new Error(InternalError, 'Midi port already open')));
                return;
            }
            var i = 0;
            midiAccess.outputs.forEach(function(value:MIDIOutput, key:String, map) {
                if (i == portNumber) {
                    value.open().then(function(_midiOutput:MIDIPort) {
                        midiOutput = cast _midiOutput;
                        callback(Success(this));
                    });
                    i = -1;
                    return;
                }
                i++;
            });
            if (i != -1) callback(Failure(new Error(InternalError, 'Port number out of range: $portNumber')));
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, Error>
    {
        return Future.async(function(_callback) {
            _callback(Failure(new Error(InternalError, 'Virtual ports not supported')));
        });
    }

    public function closePort():Void
    {
        if (midiOutput != null) {
            midiOutput.close().then(function(_midiOutput:MIDIPort) {
                midiOutput = null;
            });
        }
    }

    public function isPortOpen():Bool
    {
        return (midiOutput != null && midiOutput.state == CONNECTED);
    }

    public function sendMessage(midiMessage:MidiMessage)
    {
        try {
            midiOutput.send(midiMessage.toArray());
        }
        catch (error:js.lib.Error) {
            throw new Error(InternalError, error.message);
        }
    }
}

#end