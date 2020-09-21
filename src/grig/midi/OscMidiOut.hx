package grig.midi; #if (grig.osc)

import grig.osc.Client;
import grig.osc.Message;
import haxe.io.Bytes;

class OscMidiOut implements MidiSender
{
    private var client:Client;

    public function new(client:Client)
    {
        this.client = client;
    }

    public function sendMessage(midiMessage:MidiMessage):Void
    {
        var message = new Message('/midi');
        var bytes = Bytes.alloc(4);
        bytes.blit(0, midiMessage.getBytes(), 0, midiMessage.length);
        message.arguments.push(new grig.osc.argument.MidiArgument(bytes));
        client.sendMessage(message);
    }
}

#end