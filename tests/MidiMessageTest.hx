package;

import grig.midi.MidiMessage;
import tink.unit.Assert.*;

@:asserts
class MidiMessageTest
{
    private var midiMessage:MidiMessage;

    public function new()
    {
        midiMessage = MidiMessage.ofArray([0x81, 0x30, 0x50]);
    }

    public function testByte1()
    {
        return assert(midiMessage.byte1 == 0x81);
    }

    public function testByte2()
    {
        return assert(midiMessage.byte2 == 0x30);
    }

    public function testByte3()
    {
        return assert(midiMessage.byte3 == 0x50);
    }

    public function testChannel()
    {
        return assert(midiMessage.channel == 1);
    }

    public function testType()
    {
        return assert(midiMessage.messageType == NoteOff);
    }

}
