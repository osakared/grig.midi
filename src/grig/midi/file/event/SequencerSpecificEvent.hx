package grig.midi.file.event;

import haxe.io.Bytes;

using grig.midi.file.VariableLengthWriter;

class SequencerSpecificEvent implements MidiFileEvent
{
    public var bytes(default, null):Bytes;
    public var absoluteTime(default, null):Int; // In ticks
    public var id(default, null):Int;

    public function new(_bytes:Bytes, _id:Int, _absoluteTime:Int)
    {
        bytes = _bytes;
        id = _id;
        absoluteTime = _absoluteTime;
    }

    public static function fromInput(input:haxe.io.Input, length:Int, absoluteTime:Int)
    {
        var id = input.readByte() << 0x10;
        length -= 1;
        if (id == 0) {
            id |= input.readByte() << 0x08;
            id |= input.readByte();
            length -= 2;
        }
        var bytes = input.read(length);
        return new SequencerSpecificEvent(bytes, id, absoluteTime);
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x7F);
        }
        var written = output.writeVariableBytes(bytes.length, null, dry) + bytes.length + 2;
        if (!dry) {
            output.writeBytes(bytes, 0, bytes.length);
        }
        return written;
    }
    
    public function toString()
        return '[SequencerSpecificEvent: absoluteTime($absoluteTime) / id($id) / bytes($bytes)]';
}
