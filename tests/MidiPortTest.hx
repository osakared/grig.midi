package;

import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import tink.unit.Assert.*;

@:asserts
class MidiPortTest {

    public function new()
    {
    }

    @:exclude
    public function testPorts()
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

}
