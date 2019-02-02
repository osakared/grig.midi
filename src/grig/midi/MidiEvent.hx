package grig.midi;

class MidiEvent
{
    public var midiMessage(default, null):MidiMessage;
    public var absoluteTime(default, null):Int; // In ticks

    public function new(_midiMessage:MidiMessage, _absoluteTime:Int)
    {
        midiMessage = _midiMessage;
        absoluteTime = _absoluteTime;
    }
}