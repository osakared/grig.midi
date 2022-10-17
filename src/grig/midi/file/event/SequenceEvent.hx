package grig.midi.file.event;

class SequenceEvent extends MidiFileEvent
{
    public var sequenceNumber(default, null):Int;

    public function new(sequenceNumber:Int, absoluteTime:Int)
    {
        super(Sequence(this), absoluteTime);
        this.sequenceNumber = sequenceNumber;
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x51);
            output.writeByte(0x02);
            output.writeUInt16(sequenceNumber);
        }
        return 5;
    }
    
    override public function toString()
        return '[SequenceEvent: absoluteTime($absoluteTime) / sequenceNumber($sequenceNumber)]';
}