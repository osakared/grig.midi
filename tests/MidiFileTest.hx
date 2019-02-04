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
        return assert(midiFile.tracks.length == 14);
    }

    public function testFirstBassNote()
    {
        for (midiEvent in midiFile.tracks[2].midiEvents) {
            if (midiEvent.midiMessage.messageType == NoteOn) {
                return assert(midiEvent.midiMessage.byte2 == 0x3E);
            }
        }
        return assert(false);
    }

    public function testWrite()
    {
        var output = new haxe.io.BytesOutput();
        midiFile.write(output);
        output.close();

        // // For manual testing.. won't work on targets without full sys implementation!
        // var fileOutput = sys.io.File.write('test.mid', true);
        // midiFile.write(fileOutput);
        // fileOutput.close();

        var bytes = output.getBytes();
        var newInput = new BytesInput(bytes);
        var newMidiFile = MidiFile.fromInput(newInput);
        for (midiEvent in newMidiFile.tracks[2].midiEvents) {
            if (midiEvent.midiMessage.messageType == NoteOn) {
                return assert(midiEvent.midiMessage.byte2 == 0x3E);
            }
        }
        return assert(false);
    }

    public function testFormat0()
    {
        var bytes = Resource.getBytes('tests/heart_of_glass.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        return assert(midiFile.tracks.length == 1 && midiFile.format == 0);
    }

    public function testFormat2()
    {
        var bytes = Resource.getBytes('tests/impmarch.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        return assert(midiFile.tracks.length == 2 && midiFile.format == 2);
    }

}
