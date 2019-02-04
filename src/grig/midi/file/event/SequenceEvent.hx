package grig.midi.file.event;

class SequenceEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var sequenceNumber(default, null):Int;

    public function new(_sequenceNumber:Int, _absoluteTime:Int)
    {
        sequenceNumber = _sequenceNumber;
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x51);
            output.writeByte(0x02);
            output.writeUInt16(sequenceNumber);
        }
        return 5;
    }
}