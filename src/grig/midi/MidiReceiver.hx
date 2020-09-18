package grig.midi;

interface MidiReceiver
{
    public function setCallback(callback:(MidiMessage, Float)->Void):Void;
}