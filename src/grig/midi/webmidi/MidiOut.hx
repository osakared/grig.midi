package grig.midi.webmidi; #if (js && !nodejs)

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiOut
{
    private var midiAccess:MIDIAccess;
    private var midiOutput:MIDIOutput;
    private var midiAccessFuture:js.Promise<Void>;
    private var ports:Array<String>;

    public function new()
    {
        ports = new Array<String>();

        var nagivator:Navigator = Browser.window.navigator;
        if (untyped __js__('navigator.requestMIDIAccess != undefined')) {
            midiAccessFuture = nagivator.requestMIDIAccess().then(function(_midiAccess:MIDIAccess) {
                midiAccess = _midiAccess;
                midiAccess.outputs.forEach(function(value:MIDIOutput, key:String, map) {
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

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, Error>
    {
        return Future.async(function(_callback) {
            if (midiAccess == null) {
                _callback(Failure(new Error(InternalError, 'MIDIOutput not available')));
                return;
            }
            if (isPortOpen()) {
                _callback(Failure(new Error(InternalError, 'Midi port already open')));
                return;
            }
            var i = 0;
            midiAccess.outputs.forEach(function(value:MIDIOutput, key:String, map) {
                if (i == portNumber) {
                    value.open().then(function(_midiOutput:MIDIOutput) {
                        midiOutput = _midiOutput;
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

    public function openVirtualPort(portName:String):Surprise<MidiOut, Error>
    {
        return Future.async(function(_callback) {
            _callback(Failure(new Error(InternalError, 'Virtual ports not supported')));
        });
    }

    public function closePort():Void
    {
        if (midiOutput != null) {
            midiOutput.close().then(function(_midiOutput:MIDIOutput) {
                midiOutput = null;
            });
        }
    }

    public function isPortOpen():Bool
    {
        return (midiOutput != null && midiOutput.state == 'connected');
    }

    public function sendMessage(midiMessage:MidiMessage)
    {
        try {
            midiOutput.send([midiMessage.byte1, midiMessage.byte2, midiMessage.byte3]);
        }
        catch (error:js.Error) {
            throw new Error(InternalError, error.message);
        }
    }
}

#end