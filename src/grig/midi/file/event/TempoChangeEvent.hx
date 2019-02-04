package grig.midi.file.event;

class TempoChangeEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var microsecondsPerQuarterNote(default, null):Int;
    public var tempo(get, null):Int;

    private function get_tempo():Int
    {
        return Std.int(1000000 / microsecondsPerQuarterNote) * 60;
    }

    public function new(_microsecondsPerQuarterNote:Int, _absoluteTime:Int)
    {
        microsecondsPerQuarterNote = _microsecondsPerQuarterNote;
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x51);
            output.writeByte(0x03);
            output.writeUInt24(microsecondsPerQuarterNote);
        }
        return 6;
    }
}
