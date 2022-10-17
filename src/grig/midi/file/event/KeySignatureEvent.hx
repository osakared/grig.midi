package grig.midi.file.event;

class KeySignatureEvent extends MidiFileEvent
{
    public var numSharps(default, null):Int;
    public var isMinor(default, null):Bool;

    public function new(numSharps:Int, isMinor:Bool, absoluteTime:Int)
    {
        super(KeySignature(this), absoluteTime);
        this.numSharps = numSharps;
        this.isMinor = isMinor;
    }

    public static function fromInput(input:haxe.io.Input, absoluteTime:Int)
    {
        var numSharps = input.readByte();
        var isMinor:Bool = input.readByte() == 1;
        return new KeySignatureEvent(numSharps, isMinor, absoluteTime);
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x59);
            output.writeByte(0x02);
            output.writeByte(numSharps);
            output.writeByte(isMinor ? 1 : 0);
        }
        return 5;
    }
    
    override public function toString()
        return '[KeySignatureEvent: absoluteTime($absoluteTime) / numSharps($numSharps) / isMinor($isMinor)]';
}