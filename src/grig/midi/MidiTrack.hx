package grig.midi;

import haxe.io.Input;
import haxe.io.Output;
import tink.core.Pair;

using grig.midi.file.VariableLengthReader;
using grig.midi.file.VariableLengthWriter;

class MidiTrack
{
    private static inline var MIDI_TRACK_HEADER_TAG:UInt = 0x4D54726B; // MTrk
    
    public var midiEvents(default, null):Array<grig.midi.file.event.MidiFileEvent>; // should be sorted by time

    private function new()
    {
        midiEvents = new Array<grig.midi.file.event.MidiFileEvent>();
    }

    public static function fromInput(input:Input, parent:MidiFile)
    {
        var headerTag = input.readInt32();
        if (headerTag != MIDI_TRACK_HEADER_TAG) {
            throw "Not a valid midi track";
        }

        var size = input.readInt32(); 
        var absoluteTime:Int = 0;
        var midiTrack = new MidiTrack();
        var lastFlag:Int = 0; // for running status

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

            else if (flag == 0xFF) {
                var type = input.readByte();
                var metaLength = input.readVariableBytes();
                size = size - 1 - metaLength.length - metaLength.value;
                switch (type) {
                    case 0x00: midiTrack.midiEvents.push(new grig.midi.file.event.SequenceEvent(input.readUInt16(), absoluteTime));
                    case 0x01 | 0x02 | 0x03 | 0x04 | 0x05 | 0x06 | 0x07 : {
                        midiTrack.midiEvents.push(new grig.midi.file.event.TextEvent(input.readString(metaLength.value), absoluteTime, type));
                    }
                    case 0x2F: midiTrack.midiEvents.push(new grig.midi.file.event.EndTrackEvent(absoluteTime));
                    case 0x51: midiTrack.midiEvents.push(new grig.midi.file.event.TempoChangeEvent(input.readUInt24(), absoluteTime));
                    case 0x58: {
                        var numerator = input.readByte();
                        var denominator = input.readByte();
                        var midiClocksPerClick = input.readByte();
                        var thirtySecondNotesPerTick = input.readByte();
                        midiTrack.midiEvents.push(new grig.midi.file.event.TimeSignatureEvent(numerator, denominator, midiClocksPerClick, thirtySecondNotesPerTick, absoluteTime));
                    }
                    case 0x59: {
                        var numSharps = input.readByte();
                        var isMinor:Bool = input.readByte() == 1;
                        midiTrack.midiEvents.push(new grig.midi.file.event.KeySignatureEvent(numSharps, isMinor, absoluteTime));
                    }
                    default: input.readString(metaLength.value); // left out midi channel prefix, smtpe start, sequencer-specific meta event
                }
            }

            // Okay I think it's a message
            else {
                var messageType = MidiMessage.messageTypeForByte(flag >> 4);
                var messageBytes:Int = 0;
                if (messageType == Unknown) { // running status
                    messageBytes = lastFlag << 0x10;
                    messageType = MidiMessage.messageTypeForByte(lastFlag >> 4);
                }
                else {
                    messageBytes = flag << 0x10;
                    lastFlag = flag;
                }
                // implement running status
                var messageSize = MidiMessage.sizeForMessageType(messageType);
                for (i in 1...(messageSize)) {
                    messageBytes |= input.readByte() << (0x08 * (2 - i));
                    size -= 1;
                }

                midiTrack.midiEvents.push(new grig.midi.file.event.MidiMessageEvent(new MidiMessage(messageBytes), absoluteTime));
            }
        }

        parent.tracks.push(midiTrack);
    }

    public function write(output:Output):Void
    {
        output.writeInt32(MIDI_TRACK_HEADER_TAG);

        var size:Int = 0;
        var previousTime:Int = 0;
        for (midiEvent in midiEvents) {
            size += output.writeVariableBytes(midiEvent.absoluteTime - previousTime, null, true);
            previousTime = midiEvent.absoluteTime;
            size += midiEvent.write(output, true);
        }
        output.writeInt32(size);

        previousTime = 0;
        for (midiEvent in midiEvents) {
            output.writeVariableBytes(midiEvent.absoluteTime - previousTime);
            previousTime = midiEvent.absoluteTime;
            midiEvent.write(output);
        }

        output.flush();
    }
}