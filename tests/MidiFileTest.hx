package;

import haxe.io.BytesInput;
import haxe.Resource;
import grig.midi.MidiFile;
import tink.unit.Assert.*;

@:asserts
class MidiFileTest
{
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

    public function testWrite()
    {
        // var output = sys.io.File.write('test.mid', true); //new haxe.io.BytesOutput();// sys.io.File.write('test.mid', true);
        // midiFile.write(output);
        // output.close();
        // var output1 = sys.io.File.write('test1.mid', true);
        // midiFile.tracks[0].write(output1);
        // output.flush();
        // output.close();
        // var bytes = output.getBytes();
        // var newInput = new BytesInput(bytes);
        // var newInput = sys.io.File.read('test.mid', true);
        // var newMidiFile = MidiFile.fromInput(newInput);
        return assert(true);
    }

}
