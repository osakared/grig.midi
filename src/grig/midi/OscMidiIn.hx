package grig.midi; #if (grig.osc)

import grig.osc.argument.MidiArgument;
import grig.osc.Server;
import haxe.Timer;

/**
 * Midi receiver that works via OSC
 */
class OscMidiIn implements grig.midi.MidiReceiver
{
    private var callback:(MidiMessage, Float)->Void;
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
        var bytes = midiArgument.midiBytes.sub(0, MidiMessage.sizeForMessageType(MidiMessage.messageTypeForByte(midiArgument.midiBytes.get(0))));
        var midiMessage = new MidiMessage(bytes);
        var newMessageTime = Timer.stamp();
        if (lastMessageTime == null) lastMessageTime = newMessageTime;
        var delta:Float = newMessageTime - lastMessageTime;
        lastMessageTime = newMessageTime;
        callback(midiMessage, delta);
    }

    public function setCallback(callback:(MidiMessage, Float)->Void):Void
    {
        this.callback = callback;
    }
}

#end
