package grig.midi.file.event;

class SmtpeOffsetEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var hours(default, null):Int;
    public var minutes(default, null):Int;
    public var seconds(default, null):Int;
    public var frames(default, null):Int;
    public var fractionalFrames(default, null):Int;

    public function new(_hours:Int, _minutes:Int, _seconds:Int, _frames:Int, _fractionalFrames, _absoluteTime:Int)
    {
        hours = _hours;
        minutes = _minutes;
        seconds = _seconds;
        frames = _frames;
        fractionalFrames = _fractionalFrames;
        absoluteTime = _absoluteTime;
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

    public function write(output:haxe.io.Output, dry:Bool = false):Int
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
}