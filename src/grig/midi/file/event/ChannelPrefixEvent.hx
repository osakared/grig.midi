package grig.midi.file.event;

class ChannelPrefixEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var channelPrefix(default, null):Int;

    public function new(_channelPrefix:Int, _absoluteTime:Int)
    {
        channelPrefix = _channelPrefix;
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x20);
            output.writeByte(0x01);
            output.writeByte(channelPrefix);
        }
        return 5;
    }
}