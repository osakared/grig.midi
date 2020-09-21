package grig.midi.file.event;

class MidiMessageEvent implements MidiFileEvent
{
    public var midiMessage(default, null):MidiMessage;
    public var absoluteTime(default, null):Int; // In ticks

    public function new(_midiMessage:MidiMessage, _absoluteTime:Int)
    {
        midiMessage = _midiMessage;
        absoluteTime = _absoluteTime;
    }

    public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (dry) return midiMessage.size;
        for (i in 0...midiMessage.size) {
            output.writeByte(midiMessage.get(i));
        }
        return midiMessage.size;
    }
}