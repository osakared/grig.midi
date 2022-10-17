package grig.midi.file.event;

class EndTrackEvent extends MidiFileEvent
{
    public function new(absoluteTime:Int)
    {
        super(EndTrack(this), absoluteTime);
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x2F);
            output.writeByte(0x00);
        }
        return 3;
    }
    
    override public function toString()
        return '[EndTrackEvent: absoluteTime($absoluteTime)]';
}