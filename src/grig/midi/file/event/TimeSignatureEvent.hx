package grig.midi.file.event;

class TimeSignatureEvent extends MidiFileEvent
{
    public var numerator(default, null):Int;
    public var denominatorExponent(default, null):Int;
    public var denominator(get, never):Int;
    public var midiClocksPerClick(default, null):Int;
    public var thirtySecondNotesPerTick(default, null):Int;

    private function get_denominator():Int
    {
        return Math.ceil(Math.pow(2, denominatorExponent));
    }

    public function new(numerator:Int, denominatorExponent:Int, midiClocksPerClick:Int, thirtySecondNotesPerTick:Int, absoluteTime:Int)
    {
        super(TimeSignature(this), absoluteTime);
        this.midiClocksPerClick = midiClocksPerClick;
        this.thirtySecondNotesPerTick = thirtySecondNotesPerTick;
        this.numerator = numerator;
        this.denominatorExponent = denominatorExponent;
    }

    public static function fromInput(input:haxe.io.Input, absoluteTime:Int)
    {
        var numerator = input.readByte();
        var denominator = input.readByte();
        var midiClocksPerClick = input.readByte();
        var thirtySecondNotesPerTick = input.readByte();
        return new TimeSignatureEvent(numerator, denominator, midiClocksPerClick, thirtySecondNotesPerTick, absoluteTime);
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) {
            output.writeByte(0xFF);
            output.writeByte(0x58);
            output.writeByte(0x04);
            output.writeByte(numerator);
            output.writeByte(denominatorExponent);
            output.writeByte(midiClocksPerClick);
            output.writeByte(thirtySecondNotesPerTick);
        }
        return 7;
    }
    
    override public function toString()
        return '[TimeSignatureEvent: absoluteTime($absoluteTime) / numerator($numerator) / denominatorExponent($denominatorExponent) / denominator($denominator) / midiClocksPerClick($midiClocksPerClick) / thirtySecondNotesPerTick($thirtySecondNotesPerTick)]';
}
