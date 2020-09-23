package grig.midi.java; #if java

import java.javax.sound.midi.MidiDevice;
import java.javax.sound.midi.MidiSystem;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

@:allow(grig.midi.java.MidiReceiver)
class MidiIn extends grig.midi.MidiInBase
{
    private var receiver:MidiReceiver;
    private var device:MidiDevice;
    private var portOpen:Bool = false;

    private function handleMidiEvent(midiMessage:grig.midi.MidiMessage, delta:Float):Void
    {
        if (callback != null) callback(midiMessage, delta);
    }

    public function new(api:grig.midi.Api = grig.midi.Api.Unspecified)
    {
        receiver = new MidiReceiver(this);
    }

    public static function getApis():Array<Api>
    {
        return [];
    }

    public function getPorts():Surprise<Array<String>, Error>
    {
        return Future.async((_callback) -> {
            try {
                var ports = new Array<String>();
                var infos = MidiSystem.getMidiDeviceInfo();
                for (info in infos) {
                    ports.push(info.getName());
                }
                _callback(Success(ports));
            }
            catch (exception:java.lang.Exception) {
                _callback(Failure(new Error(InternalError, '$exception')));
            }
        });
    }

    public function openPort(portNumber:Int, portName:String):Surprise<MidiIn, Error>
    {
        return Future.async((_callback) -> {
            try {
                if (device != null) {
                    return _callback(Failure(new Error(InternalError, 'Already connected')));
                }
                var infos = MidiSystem.getMidiDeviceInfo();
                if (infos.length <= portNumber) {
                    return _callback(Failure(new Error(InternalError, 'Unknown port')));
                }
                var info = infos[portNumber];
                device = MidiSystem.getMidiDevice(info);
                device.open();
                var transmitter = device.getTransmitter();
                transmitter.setReceiver(receiver);
                _callback(Success(this));
            }
            catch (exception:java.lang.Exception) {
                _callback(Failure(new Error(InternalError, '$exception')));
            }
        });
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
        return portOpen;
    }
}

#end