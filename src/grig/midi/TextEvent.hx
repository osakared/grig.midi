package grig.midi;

import haxe.io.Bytes;

using grig.midi.VariableLengthWriter;

enum TextEventType {
    Lyric;
    Marker;
    CuePoint;
}

class TextEvent implements MidiFileEvent
{
    public var bytes(default, null):Bytes;
    public var absoluteTime(default, null):Int; // In ticks
    public var type(default, null):TextEventType;

    public function new(_text:String, _absoluteTime:Int, _type:TextEventType)
    {
        bytes = Bytes.ofString(_text, UTF8);
        absoluteTime = _absoluteTime;
        type = _type;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        var written = output.writeVariableBytes(bytes.length, null, dry);
        if (!dry) output.writeBytes(bytes, 0, bytes.length);
        return written;
    }
}
