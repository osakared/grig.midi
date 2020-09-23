package grig.midi.java; #if java

import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiIn extends grig.midi.MidiInBase
{
    // private function handleMidiEvent(midiMessageEvent:MIDIMessageEvent)
    // {
    //     if (callback != null) {
    //         callback(MidiMessage.ofBytesData(midiMessageEvent.data.buffer), midiMessageEvent.timeStamp - lastTime);
    //         lastTime = midiMessageEvent.timeStamp;
    //     }
    // }

    public function new(api:grig.midi.Api = grig.midi.Api.Unspecified)
    {
    }

    public static function getApis():Array<Api>
    {
        return [];
    }

    public function getPorts():Surprise<Array<String>, Error>
    {
        return Future.sync(Failure(new Error(InternalError, 'Not implemented for managed-midi')));
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, Error>
    {
        return Future.sync(Failure(new Error(InternalError, 'Not implemented for managed-midi')));
    }

    public function openVirtualPort(portName:String):Surprise<MidiIn, Error>
    {
        return Future.sync(Failure(new Error(InternalError, 'Virtual ports not supported')));
    }

    public function closePort():Void
    {
    }

    public function isPortOpen():Bool
    {
        return false;
    }
}

#end