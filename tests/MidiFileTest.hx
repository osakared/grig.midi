package;

import haxe.io.BytesInput;
import haxe.Resource;
import music.midi.MidiFile;
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

}
