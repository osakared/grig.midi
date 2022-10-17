package grig.midi.file.event;

class MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var type(default, null):MidiFileEventType;

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        return 0;
    }

    public function toString():String
    {
        return "";
    }

    private function new(type:MidiFileEventType, absoluteTime:Int)
    {
        this.type = type;
        this.absoluteTime = absoluteTime;
    }
}
