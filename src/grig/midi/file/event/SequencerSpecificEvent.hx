package grig.midi.file.event;

import haxe.io.Bytes;

using grig.midi.file.VariableLengthWriter;

class SequencerSpecificEvent extends MidiFileEvent
{
    public var bytes(default, null):Bytes;
    public var id(default, null):Int;

    public function new(bytes:Bytes, id:Int, absoluteTime:Int)
    {
        super(SequencerSpecific(this), absoluteTime);
        this.bytes = bytes;
        this.id = id;
    }

    public static function fromInput(input:haxe.io.Input, length:Int, absoluteTime:Int):SequencerSpecificEvent
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

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
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
    
    override public function toString()
        return '[SequencerSpecificEvent: absoluteTime($absoluteTime) / id($id) / bytes($bytes)]';
}
