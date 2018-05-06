package music.midi;

import haxe.io.Input;

using music.midi.VariableLengthReader;

class MidiTrack
{
    private static inline var MIDI_TRACK_HEADER_TAG:UInt = 0x4D54726B; // MTrk
    
    public var midiEvents(default, null):Array<MidiEvent>; // should be sorted by time

    private function new()
    {
        midiEvents = new Array<MidiEvent>();
    }

    public static function fromInput(input:Input, parent:MidiFile):MidiTrack
    {
        if (input.readInt32() != MIDI_TRACK_HEADER_TAG) {
            throw "Not a valid midi track";
        }

        var size = input.readInt32();
        var absoluteTime:Float = 0.0;
        var midiTrack = new MidiTrack();
        var lastFlag:Int = 0;

        while (size > 0) {
            var variableBytes = input.readVariableBytes();
            size -= variableBytes.length;
            var delta:Float = variableBytes.value / parent.timeDivision;
            absoluteTime += delta;
            var flag = input.readByte();
            size -= 1;

            // Sysex, to be ignored.. read until end of sysex to continue
            if (flag == 0xF0) {
                while (true) {
                    size -= 1;
                    if (input.readByte() == 0xF7) {
                        break;
                    }
                }
            }

            // Meta, also ignoring for now
            else if (flag == 0xFF) {
                var type = input.readByte();
                size -= 1;
                if (type == 0x2F) {
                    input.readByte();
                    size -= 1;
                }
                else {
                    variableBytes = input.readVariableBytes();
                    size -= variableBytes.length;
                    input.read(variableBytes.value);
                    size -= variableBytes.value;
                }
            }

            // Okay I think it's a message
            else {
                var messageBytes:Int = flag;
                if (flag & 0x80 != 0) {
                    messageBytes |= input.readByte() << 8;
                    size -= 1;
                    lastFlag = flag;
                }
                else {
                    messageBytes = lastFlag;
                    messageBytes |= flag << 8;
                }
                messageBytes |= input.readByte();
                size -= 1;

                midiTrack.midiEvents.push(new MidiEvent(new MidiMessage(messageBytes), absoluteTime));
            }
        }

        return midiTrack;
    }
}