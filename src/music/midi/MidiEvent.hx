package music.midi;

class MidiEvent
{
    public var midiMessage(default, null):MidiMessage;
    public var absoluteTime(default, null):Float;

    public function new(_midiMessage:MidiMessage, _absoluteTime:Float)
    {
        midiMessage = _midiMessage;
        absoluteTime = _absoluteTime;
    }
}