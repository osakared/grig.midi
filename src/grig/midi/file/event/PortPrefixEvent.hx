package grig.midi.file.event;

class PortPrefixEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var portPrefix(default, null):Int;

    public function new(_portPrefix:Int, _absoluteTime:Int)
    {
        portPrefix = _portPrefix;
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x21);
            output.writeByte(0x01);
            output.writeByte(portPrefix);
        }
        return 4;
    }
}