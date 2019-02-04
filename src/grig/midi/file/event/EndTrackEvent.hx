package grig.midi.file.event;

class EndTrackEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks

    public function new(_absoluteTime:Int)
    {
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x2F);
            output.writeByte(0x00);
        }
        return 3;
    }
}