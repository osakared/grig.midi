package grig.midi.file.event;

class TimeSignatureEvent implements MidiFileEvent
{
    public var absoluteTime(default, null):Int; // In ticks
    public var numerator(default, null):Int;
    public var denominatorExponent(default, null):Int;
    public var denominator(get, never):Int;
    public var midiClocksPerClick(default, null):Int;
    public var thirtySecondNotesPerTick(default, null):Int;

    private function get_denominator():Int
    {
        return Math.ceil(Math.pow(2, denominatorExponent));
    }

    public function new(_numerator:Int, _denominatorExponent:Int, _midiClocksPerClick:Int, _thirtySecondNotesPerTick:Int, _absoluteTime:Int)
    {
        midiClocksPerClick = _midiClocksPerClick;
        thirtySecondNotesPerTick = _thirtySecondNotesPerTick;
        numerator = _numerator;
        denominatorExponent = _denominatorExponent;
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
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
}
