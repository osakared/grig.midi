package grig.midi.java; #if java

using thx.Int64s;

class MidiReceiver implements java.javax.sound.midi.Receiver
{
    private var midiIn:MidiIn;
    private var lastTime:Null<Int64> = null;

    public function new(midiIn:MidiIn)
    {
        this.midiIn = midiIn;
    }

    public function close():Void
    {
        midiIn.portOpen = false;
    }

    public function send(midiMessage:java.javax.sound.midi.MidiMessage, currentTime:Int64):Void
    {
        if (lastTime == null) lastTime = currentTime;
        var delta = (currentTime - lastTime).toFloat() / 1000000.0;
        lastTime = currentTime;
        var message = new grig.midi.MidiMessage(haxe.io.Bytes.ofData(midiMessage.getMessage()));
        midiIn.handleMidiEvent(message, delta);
    }
}

#end