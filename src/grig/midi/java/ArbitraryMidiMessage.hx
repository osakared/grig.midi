package grig.midi.java; #if java

class ArbitraryMidiMessage extends java.javax.sound.midi.MidiMessage
{
    public function new(midiMessage:grig.midi.MidiMessage)
    {
        super(midiMessage.getData());
    }
}

#end