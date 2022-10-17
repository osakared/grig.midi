package grig.midi.file.event;

class TempoChangeEvent extends MidiFileEvent
{
    public var microsecondsPerQuarterNote(default, null):Int;
    public var tempo(get, null):Int;

    private function get_tempo():Int
    {
        return Std.int(1000000 / microsecondsPerQuarterNote) * 60;
    }

    public function new(microsecondsPerQuarterNote:Int, absoluteTime:Int)
    {
        super(TempoChange(this), absoluteTime);
        this.microsecondsPerQuarterNote = microsecondsPerQuarterNote;
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x51);
            output.writeByte(0x03);
            output.writeUInt24(microsecondsPerQuarterNote);
        }
        return 6;
    }
    
    override public function toString()
        return '[TempoChangeEvent: absoluteTime($absoluteTime) / msPQN($microsecondsPerQuarterNote) / tempo($tempo)]';
}
