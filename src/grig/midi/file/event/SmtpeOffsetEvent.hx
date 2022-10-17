package grig.midi.file.event;

class SmtpeOffsetEvent extends MidiFileEvent
{
    public var hours(default, null):Int;
    public var minutes(default, null):Int;
    public var seconds(default, null):Int;
    public var frames(default, null):Int;
    public var fractionalFrames(default, null):Int;

    public function new(hours:Int, minutes:Int, seconds:Int, frames:Int, fractionalFrames, absoluteTime:Int)
    {
        super(SmtpeOffset(this), absoluteTime);
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
        this.frames = frames;
        this.fractionalFrames = fractionalFrames;
    }

    public static function fromInput(input:haxe.io.Input, absoluteTime:Int):SmtpeOffsetEvent
    {
        var hours = input.readByte();
        var minutes = input.readByte();
        var seconds = input.readByte();
        var frames = input.readByte();
        var fractionalFrames = input.readByte();
        return new SmtpeOffsetEvent(hours, minutes, seconds, frames, fractionalFrames, absoluteTime);
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x54);
            output.writeByte(0x05);
            output.writeByte(hours);
            output.writeByte(minutes);
            output.writeByte(seconds);
            output.writeByte(frames);
            output.writeByte(fractionalFrames);
        }
        return 8;
    }
    
    override public function toString()
        return '[SmtpeOffsetEvent: absoluteTime($absoluteTime) / hours($hours) / minutes($minutes) / seconds($seconds) / frames($frames) / fractionalFrames($fractionalFrames)]';
}