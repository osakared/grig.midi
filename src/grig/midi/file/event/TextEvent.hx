package grig.midi.file.event;

import haxe.io.Bytes;

using grig.midi.file.VariableLengthWriter;

enum TextEventType {
    Lyric;
    Marker;
    CuePoint;
    TextEvent;
    Copyright;
    SequenceName;
    InstrumentName;
}

class TextEvent extends MidiFileEvent
{
    public var bytes(default, null):Bytes;
    public var textEventType(default, null):TextEventType;

    public static function typeFromByte(byte:Int):TextEventType
    {
        switch (byte) {
            case 0x01: return TextEvent;
            case 0x02: return Copyright;
            case 0x03: return SequenceName;
            case 0x04: return InstrumentName;
            case 0x05: return Lyric;
            case 0x06: return Marker;
            case 0x07: return CuePoint;
            default: throw 'Unknown type: ' + StringTools.hex(byte);
        }
    }

    public static function byteFromType(_type:TextEventType):Int
    {
        switch (_type) {
            case TextEvent: return 0x01;
            case Copyright: return 0x02;
            case SequenceName: return 0x03;
            case InstrumentName: return 0x04;
            case Lyric: return 0x05;
            case Marker: return 0x06;
            case CuePoint: return 0x07;
        }
        throw 'Unknown type ' + _type;
        return 0;
    }

    public function new(text:String, absoluteTime:Int, type:Int)
    {
        super(Text(this), absoluteTime);
        this.bytes = Bytes.ofString(text, UTF8);
        this.textEventType = typeFromByte(type);
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(byteFromType(textEventType));
        }
        var written = output.writeVariableBytes(bytes.length, null, dry) + bytes.length + 2;
        if (!dry) {
            output.writeBytes(bytes, 0, bytes.length);
        }
        return written;
    }
    
    override public function toString()
        return '[TextEvent: absoluteTime($absoluteTime) / type($textEventType) / text(${bytes.getString(0, bytes.length)})]';
}
