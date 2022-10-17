package grig.midi.file.event;

class ChannelPrefixEvent extends MidiFileEvent
{
    public var channelPrefix(default, null):Int;

    public function new(channelPrefix:Int, absoluteTime:Int)
    {
        super(ChannelPrefix(this), absoluteTime);
        this.channelPrefix = channelPrefix;
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x20);
            output.writeByte(0x01);
            output.writeByte(channelPrefix);
        }
        return 5;
    }
    
    override public function toString()
        return '[ChannelPrefixEvent: absoluteTime($absoluteTime) / channelPrefix($channelPrefix)]';
}