package;

import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import grig.midi.MidiOut;
import tink.unit.Assert.*;

@:asserts
class MidiPortTest {

    public function new()
    {
    }

    @:exclude
    public function testMidiIn()
    {
        var midiIn = new MidiIn();
        trace(midiIn.getPorts());
        midiIn.setCallback(function (midiMessage:MidiMessage, delta:Float) {
            trace(midiMessage.messageType);
        });
        midiIn.openPort(0, 'grig.midi');
        Sys.sleep(5);
        midiIn.closePort();
        return assert(true);
    }

    @:exclude
    public function testMidiOut()
    {
        var midiOut = new MidiOut();
        trace(midiOut.getPorts());
        midiOut.openPort(0, 'grig.midi');
        for (i in 1...5) {
            Sys.sleep(1);
            midiOut.sendMessage(new MidiMessage(9455930));
            Sys.sleep(1);
            midiOut.sendMessage(new MidiMessage(8407360));
        }
        midiOut.closePort();
        return assert(true);
    }

}
