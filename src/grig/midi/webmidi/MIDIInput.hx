package grig.midi.webmidi;

@:native('MIDIInput')
extern class MIDIInput
{
    public var name:String;
    public var onmidimessage:(midiMessage:MIDIMessageEvent)->Void;
    public function open():js.Promise<MIDIInput>;
}
