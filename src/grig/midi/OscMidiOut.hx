package grig.midi; #if (grig.osc)

import grig.osc.Client;
import grig.osc.Message;
import haxe.io.Bytes;

class OscMidiOut implements MidiSender
{
    private static inline var MAX_LENGTH = 4;

    private var client:Client;

    public function new(client:Client)
    {
        this.client = client;
    }

    public function sendMessage(midiMessage:MidiMessage):Void
    {
        // We won't be able to accurately send this if it's a long sysex message
        if (midiMessage.length > MAX_LENGTH) return;
        var message = new Message('/midi');
        var bytes = Bytes.alloc(MAX_LENGTH);
        bytes.blit(0, midiMessage.getBytes(), 0, midiMessage.length);
        message.arguments.push(new grig.osc.argument.MidiArgument(bytes));
        client.sendMessage(message);
    }
}

#end