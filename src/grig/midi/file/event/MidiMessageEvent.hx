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
        output.write(midiMessage.getBytes());
        return midiMessage.size;
    }
    
    public function toString()
        return '[MidiMessageEvent: absoluteTime($absoluteTime) / midiMessage($midiMessage)]';
}