package grig.midi.java; #if java

import java.javax.sound.midi.MidiDevice;
import java.javax.sound.midi.MidiSystem;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class MidiOut implements grig.midi.MidiSender
{
    private var device:MidiDevice;
    private var receiver:java.javax.sound.midi.Receiver;
    private var portOpen:Bool = false;

    public function new(api:grig.midi.Api = grig.midi.Api.Unspecified)
    {
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

    public function openPort(portNumber:Int, portName:String):Surprise<MidiOut, Error>
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
                portOpen = true;
                receiver = device.getReceiver();
                _callback(Success(this));
            }
            catch (exception:java.lang.Exception) {
                _callback(Failure(new Error(InternalError, '$exception')));
            }
        });
    }

    public function openVirtualPort(portName:String):Surprise<MidiOut, Error>
    {
        return Future.sync(Failure(new Error(InternalError, 'Virtual ports not supported')));
    }

    public function closePort():Void
    {
        if (device == null) return;
        device.close();
        portOpen = false;
    }

    public function isPortOpen():Bool
    {
        return receiver != null && portOpen;
    }

    public function sendMessage(midiMessage:MidiMessage)
    {
        if (!isPortOpen()) return;
        var message = new ArbitraryMidiMessage(midiMessage);
        receiver.send(message, -1);
    }
}

#end