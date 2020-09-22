package grig.midi.cs.managedmidi; #if cs

import commons.music.midi.IMidiInput;
import commons.music.midi.MidiAccessManager;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;
import grig.midi.Api;

using thx.Int64s;

class MidiIn extends grig.midi.MidiInBase
{
    private var input:IMidiInput = null;
    private var lastTimestamp:Null<haxe.Int64> = null;

    private function handleMidiEvent(sender:Dynamic, event:commons.music.midi.MidiReceivedEventArgs):Void
    {
        // timestamps are nanoseconds (!)
        var timestamp:haxe.Int64 = event.Timestamp;
        if (lastTimestamp == null) lastTimestamp = timestamp;
        var message = new grig.midi.MidiMessage(haxe.io.Bytes.ofData(event.Data));
        callback(message, (timestamp - lastTimestamp).toFloat() / 1000000000.0);
        lastTimestamp = timestamp;
    }

    public function new(api:Api = Api.Unspecified)
    {
        // Doesn't appear to be a way to select the api here, that's determined by what you link to I guess?
    }

    public static function getApis():Array<Api>
    {
        return [];
    }

    public function getPorts():Surprise<Array<String>, tink.core.Error>
    {
        var ports = new Array<String>();
        var access = MidiAccessManager.Default;
        var e = access.Inputs.GetEnumerator();
        while (e.MoveNext()) {
            ports.push(e.Current.Name);
        }
        return Future.sync(Success(ports));
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.async((_callback) -> {
            var access = MidiAccessManager.Default;
            var e = access.Inputs.GetEnumerator();
            for (i in 0...(portNumber+1)) {
                e.MoveNext();
                if (e.Current == null) return _callback(Failure(new Error(InternalError, 'Port not found')));
            }
            var portId = e.Current.Id;
            // Ideally this should be asynchronous but I couldn't figure out how to do that in haxe/cs
            input = cast access.OpenInputAsync(portId).Result;
            trace(Type.getClassName(Type.getClass(input)));
            var eventHandler = new cs.system.EventHandler_1(handleMidiEvent);
            // Haxe thinks it's private, like in the base class, so I have to force it like this
            untyped __cs__('this._gthis.input.MessageReceived += eventHandler');
            _callback(Success(this));
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, tink.core.Error>
    {
        return Future.sync(Failure(new Error(InternalError, 'Not implemented for managed-midi')));
    }

    public function closePort():Void
    {
        return; // not implemented in managed midi apparently
    }

    public function isPortOpen():Bool
    {
        // Need to register a listener or something to know for sure it hasn't been closed since opening
        return (input != null);
    }
}

#end