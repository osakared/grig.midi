package grig.midi.file.event;

class MidiMessageEvent extends MidiFileEvent
{
    public var midiMessage(default, null):MidiMessage;

    public function new(midiMessage:MidiMessage, absoluteTime:Int)
    {
        super(MidiMessage(this), absoluteTime);
        this.midiMessage = midiMessage;
    }

    override public function write(output:haxe.io.Output, dry:Bool = false):Int
    {
        if (!dry) output.write(midiMessage.getBytes());
        return midiMessage.size;
    }
    
    override public function toString()
        return '[MidiMessageEvent: absoluteTime($absoluteTime) / midiMessage($midiMessage)]';
}