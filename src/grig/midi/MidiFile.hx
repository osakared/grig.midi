package grig.midi;

import haxe.io.Input;
import haxe.io.Output;

class MidiFile
{
    // public var tempo(default, null):Float;

    private static inline var MIDI_FILE_HEADER_TAG:UInt = 0x4D546864; // MThd
	private static inline var MIDI_FILE_HEADER_SIZE:UInt = 6;

    public var tracks(default, null):Array<MidiTrack>;
    public var format(default, null):UInt;
    public var timeDivision(default, null):UInt;

    private function new()
    {
        tracks = new Array<MidiTrack>();
    }

    public static function fromInput(input:Input):MidiFile
    {
        input.bigEndian = true;
        if (input.readInt32() != MIDI_FILE_HEADER_TAG) {
            throw "Not a valid midi file";
        }
        if (input.readInt32() != MIDI_FILE_HEADER_SIZE) {
            throw "Invalid header size in midi file";
        }

        var midiFile = new MidiFile();

        midiFile.format = input.readUInt16();
		var numTracks:UInt = input.readUInt16();
        midiFile.timeDivision = input.readUInt16();

        for (i in 0...numTracks) {
            MidiTrack.fromInput(input, midiFile);
        }

        return midiFile;
    }

    public function write(output:Output):Void
    {
        output.bigEndian = true;
        output.writeInt32(MIDI_FILE_HEADER_TAG);
        output.writeInt32(MIDI_FILE_HEADER_SIZE);
        output.writeUInt16(format);
        output.writeUInt16(tracks.length);
        output.writeUInt16(timeDivision);

        for (track in tracks) {
            track.write(output);
        }
    }
}
