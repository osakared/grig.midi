package grig.midi; #if (grig.osc)

import grig.osc.argument.MidiArgument;
import grig.osc.Server;
import haxe.Timer;

/**
 * Midi receiver that works via OSC
 */
class OscMidiIn extends grig.midi.MidiInBase
{
    private var lastMessageTime:Null<Float> = null;
    
    public function new()
    {
    }

    public function listenToServer(server:grig.osc.Server, address:String):Void
    {
        server.registerCallback(oscCallback, address, false, [grig.osc.argument.ArgumentType.Midi]);
    }

    private function oscCallback(message:grig.osc.Message)
    {
        if (callback == null) return;
        var midiArgument:grig.osc.argument.MidiArgument = cast message.arguments[0];
        var messageType = MessageType.ofByte(midiArgument.midiBytes.get(0));
        var bytesLength = if (messageType == SysEx) {
            var finalByte = 0;
            for (i in 0...midiArgument.midiBytes.length) {
                if (midiArgument.midiBytes.get(i) == 0xf7) {
                    finalByte = i + 1;
                    break;
                }
            }
            finalByte;
        }
        else {
            MidiMessage.sizeForMessageType(messageType);
        }
        var bytes = midiArgument.midiBytes.sub(0, bytesLength);
        var midiMessage = new MidiMessage(bytes);
        var newMessageTime = Timer.stamp();
        if (lastMessageTime == null) lastMessageTime = newMessageTime;
        var delta:Float = newMessageTime - lastMessageTime;
        lastMessageTime = newMessageTime;
        callback(midiMessage, delta);
    }
}

#end
