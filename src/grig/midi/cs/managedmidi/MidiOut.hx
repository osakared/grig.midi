package grig.midi.cs.managedmidi; #if cs

import commons.music.midi.IMidiOutput;
import commons.music.midi.MidiAccessManager;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiOut implements grig.midi.MidiSender
{
    private var output:IMidiOutput = null;

    public function new(api:grig.midi.Api)
    {
    }

    public static function getApis():Array<Api>
    {
        // Not implemented in managed-midi
        return [];
    }

    public function getPorts():Surprise<Array<String>, Error>
    {
        var ports = new Array<String>();
        var access = MidiAccessManager.Default;
        var e = access.Outputs.GetEnumerator();
        while (e.MoveNext()) {
            ports.push(e.Current.Name);
        }
        return Future.sync(Success(ports));
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, Error>
    {
        return Future.async((_callback) -> {
            var access = MidiAccessManager.Default;
            var e = access.Outputs.GetEnumerator();
            for (i in 0...(portNumber+1)) {
                e.MoveNext();
                if (e.Current == null) return _callback(Failure(new Error(InternalError, 'Port not found')));
            }
            var portId = e.Current.Id;
            // Ideally this should be asynchronous but I couldn't figure out how to do that in haxe/cs
            output = cast access.OpenOutputAsync(portId).Result;
            trace(Type.getClassName(Type.getClass(output)));
            _callback(Success(this));
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, Error>
    {
        return Future.sync(Failure(new Error(InternalError, 'Not implemented for managed-midi')));
    }

    public function closePort():Void
    {
        // Apparently not supported in managed-midi
        return;
    }

    public function isPortOpen():Bool
    {
        // Need to register a listener or something to know for sure it hasn't been closed since opening
        return (output != null);
    }

    public function sendMessage(midiMessage:MidiMessage)
    {
        if (output == null) return;
        output.Send(midiMessage.getData(), 0, midiMessage.size, 0);
    }
}

#end