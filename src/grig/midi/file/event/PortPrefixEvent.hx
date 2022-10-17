package grig.midi.file.event;

class PortPrefixEvent extends MidiFileEvent
{
    public var portPrefix(default, null):Int;

    public function new(portPrefix:Int, absoluteTime:Int)
    {
        super(PortPrefix(this), absoluteTime);
        this.portPrefix = portPrefix;
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x21);
            output.writeByte(0x01);
            output.writeByte(portPrefix);
        }
        return 4;
    }

    override public function toString()
    {
        return '[PortPrefixEvent: absoluteTime($absoluteTime) / portPrefix($portPrefix)]';
    }
}