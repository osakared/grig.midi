package grig.midi.file.event;


interface MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks

    public function write(output:haxe.io.Output, dry:Bool = false):Int;
}