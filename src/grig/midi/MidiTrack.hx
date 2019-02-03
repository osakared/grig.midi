package grig.midi;

import haxe.io.Input;
import haxe.io.Output;

using grig.midi.VariableLengthReader;
using grig.midi.VariableLengthWriter;

class MidiTrack
{
    private static inline var MIDI_TRACK_HEADER_TAG:UInt = 0x4D54726B; // MTrk
    
    public var midiEvents(default, null):Array<MidiEvent>; // should be sorted by time

    private function new()
    {
        midiEvents = new Array<MidiEvent>();
    }

    public static function fromInput(input:Input, parent:MidiFile)
    {
        var headerTag = input.readInt32();
        if (headerTag != MIDI_TRACK_HEADER_TAG) {
            trace(StringTools.hex(headerTag, 8));
            throw "Not a valid midi track";
        }

        var size = input.readInt32(); 
        var absoluteTime:Int = 0;
        var midiTrack = new MidiTrack();
        var lastFlag:Int = 0;

        while (size > 0) {
            var variableBytes = input.readVariableBytes();
            size -= variableBytes.length;
            var delta:Int = variableBytes.value;
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
                var messageBytes:Int = flag << 0x10;
                if (flag & 0x80 != 0) {
                    messageBytes |= input.readByte() << 8;
                    size -= 1;
                    lastFlag = flag;
                }
                else {
                    messageBytes = lastFlag << 0x10;
                    messageBytes |= flag << 8;
                }
                messageBytes |= input.readByte();
                size -= 1;

                midiTrack.midiEvents.push(new MidiEvent(new MidiMessage(messageBytes), absoluteTime));
            }
        }

        // Avoid turning just header crap into a track
        if (midiTrack.midiEvents.length > 0) {
            parent.tracks.push(midiTrack);
        }
    }

    public function write(output:Output):Void
    {
        output.writeInt32(MIDI_TRACK_HEADER_TAG);

        var size:Int = 0;
        var previousTime:Int = 0;
        for (midiEvent in midiEvents) {
            size += output.writeVariableBytes(midiEvent.absoluteTime - previousTime, null, true);
            previousTime = midiEvent.absoluteTime;
            size += 3;//midiEvent.midiMessage.size;
        }
        output.writeInt32(size);

        previousTime = 0;
        for (midiEvent in midiEvents) {
            output.writeVariableBytes(midiEvent.absoluteTime - previousTime);
            previousTime = midiEvent.absoluteTime;
            for (i in 3...0) {
                var shiftAmount = 8 * (i - 1);
                output.writeByte((midiEvent.midiMessage.bytes & (0xff << shiftAmount)) >> shiftAmount);
            }
        }

        output.flush();
    }
}