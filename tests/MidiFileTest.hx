package;

import haxe.io.BytesInput;
import haxe.Resource;
import grig.midi.MidiFile;
import tink.unit.Assert.*;

@:asserts
class MidiFileTest {

    private var midiFile:MidiFile;

    public function new()
    {
        var bytes = Resource.getBytes('tests/bohemian_rhapsody.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
    }

    public function testNumTracks()
    {
        return assert(midiFile.tracks.length == 13);
    }

    public function testFirstBassNote()
    {
        for (midiEvent in midiFile.tracks[1].midiEvents) {
            if (midiEvent.midiMessage.messageType == NoteOn) {
                return assert(midiEvent.midiMessage.byte2 == 0x3E);
            }
        }
        return assert(false);
    }

}
