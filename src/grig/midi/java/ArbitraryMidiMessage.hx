package grig.midi.java;

class ArbitraryMidiMessage extends java.javax.sound.midi.MidiMessage
{
    public function new(midiMessage:grig.midi.MidiMessage)
    {
        super(midiMessage.getData());
    }
}