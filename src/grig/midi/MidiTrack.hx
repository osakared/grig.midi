package grig.midi;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;
import tink.core.Pair;

using grig.midi.VariableLengthReader;
using grig.midi.VariableLengthWriter;

class MidiTrack
{
    private static inline var MIDI_TRACK_HEADER_TAG:UInt = 0x4D54726B; // MTrk
    
    public var midiEvents(default, null):Array<MidiFileEvent>; // should be sorted by time
    
    public var sequence(default, null):Null<Int>;
    public var text(default, null):String;
    public var copyright(default, null):String;
    public var name(default, null):String;
    public var instrument(default, null):String;
    public var endOfTrack(default, null):Int; // in ticks
    public var timeSignature(default, null):Pair<Int, Int>;
    public var midiClocksPerClick(default, null):Null<Int>;
    public var thirtySecondNotesPerTick(default, null):Null<Int>;
    public var keySignature(default, null):Pair<Int, Bool>; // number of sharps/flats, true if minor

    public static function tempoFromMsPerQuaver(microsecondsPerQuarterNote:Int):Int
    {
        return Std.int(1000000 / microsecondsPerQuarterNote) * 60;
    }

    private function new()
    {
        midiEvents = new Array<MidiFileEvent>();

        text = copyright = name = instrument = null;
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
                    case 0x00: midiTrack.sequence = input.readUInt16();
                    case 0x01: midiTrack.text = input.readString(metaLength.value);
                    case 0x02: midiTrack.copyright = input.readString(metaLength.value);
                    case 0x03: midiTrack.name = input.readString(metaLength.value);
                    case 0x04: midiTrack.instrument = input.readString(metaLength.value);
                    case 0x05: midiTrack.midiEvents.push(new TextEvent(input.readString(metaLength.value), absoluteTime, Lyric));
                    case 0x06: midiTrack.midiEvents.push(new TextEvent(input.readString(metaLength.value), absoluteTime, Marker));
                    case 0x07: midiTrack.midiEvents.push(new TextEvent(input.readString(metaLength.value), absoluteTime, CuePoint));
                    case 0x2F: midiTrack.endOfTrack = absoluteTime;
                    // case 0x51: midiTrack.microsecondsPerQuarterNote = input.readUInt24();
                    case 0x58: {
                        var numerator = input.readByte();
                        var denominator = input.readByte();
                        denominator = Math.ceil(Math.pow(2, denominator));
                        midiTrack.timeSignature = new Pair<Int, Int>(numerator, denominator);
                        midiTrack.midiClocksPerClick = input.readByte();
                        midiTrack.thirtySecondNotesPerTick = input.readByte();
                    }
                    case 0x59: {
                        var numSharps = input.readByte();
                        var isMinor:Bool = input.readByte() == 1;
                        midiTrack.keySignature = new Pair<Int, Bool>(numSharps, isMinor);
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

                midiTrack.midiEvents.push(new MidiMessageEvent(new MidiMessage(messageBytes), absoluteTime));
            }
        }

        parent.tracks.push(midiTrack);
    }

    private function writeMetaText(output:Output, type:Int, text:String)
    {
        output.writeByte(0);
        output.writeByte(0xFF);
        output.writeByte(type);
        var bytes = Bytes.ofString(text, UTF8);
        output.writeVariableBytes(bytes.length);
        output.writeBytes(bytes, 0, bytes.length);
    }

    private function metaTextSize(output:Output, text:String):Int
    {
        var bytes = Bytes.ofString(text, UTF8);
        var variableBytes = output.writeVariableBytes(bytes.length, null, true);
        return 3 + variableBytes + bytes.length;
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
        if (text != null) size += metaTextSize(output, text);
        if (copyright != null) size += metaTextSize(output, copyright);
        if (name != null) size += metaTextSize(output, name);
        if (instrument != null) size += metaTextSize(output, instrument);
        // trace(size);
        output.writeInt32(size);

        if (text != null) writeMetaText(output, 0x01, text);
        if (copyright != null) writeMetaText(output, 0x02, copyright);
        if (name != null) writeMetaText(output, 0x03, name);
        if (instrument != null) writeMetaText(output, 0x04, instrument);
        previousTime = 0;
        for (midiEvent in midiEvents) {
            output.writeVariableBytes(midiEvent.absoluteTime - previousTime);
            previousTime = midiEvent.absoluteTime;
            midiEvent.write(output);
        }

        output.flush();
    }
}