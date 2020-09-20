package grig.midi;

class MidiInBase implements MidiReceiver
{
    private var callback:(MidiMessage, Float)->Void;

    public function setCallback(_callback:(MidiMessage, Float)->Void):Void
    {
        callback = _callback;
    }

    public function cancelCallback():Void
    {
        callback = null;
    }
}