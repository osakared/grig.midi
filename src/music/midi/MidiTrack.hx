package music.midi;

import haxe.io.Input;

class MidiTrack
{
    private static inline var MIDI_TRACK_HEADER_TAG:UInt = 0x4D54726B; // MTrk
    
    public var midiEvents(default, null):Array<MidiEvent>; // should be sorted by time

    private function new()
    {
    }

    public static function fromInput(input:Input):MidiTrack
    {
        if (input.readInt32() != MIDI_TRACK_HEADER_TAG) {
            throw "Not a valid midi track";
        }

        var midiTrack = new MidiTrack();

        

        return midiTrack;
    }
}