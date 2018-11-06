package;

import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import grig.midi.MidiOut;
import haxe.Timer;
import tink.unit.Assert.*;

@:asserts
class MidiPortTest {

    private function sleep(seconds:Int)
    {
        #if !nodejs
        Sys.sleep(seconds);
        #end
    }

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
        var timer = new Timer(5000);
        sleep(5);
        midiIn.closePort();
        return assert(true);
    }

    // @:exclude
    // public function testMidiOut()
    // {
    //     var midiOut = new MidiOut();
    //     trace(midiOut.getPorts());
    //     midiOut.openPort(0, 'grig.midi');
    //     for (i in 1...5) {
    //         Sys.sleep(1);
    //         midiOut.sendMessage(new MidiMessage(9455930));
    //         Sys.sleep(1);
    //         midiOut.sendMessage(new MidiMessage(8407360));
    //     }
    //     midiOut.closePort();
    //     return assert(true);
    // }

}
