package grig.midi.webmidi;  #if (js && !nodejs)

@:native('MIDIInput')
extern class MIDIInput
{
    public var name(default, never):String;
    public var onmidimessage:(midiMessage:MIDIMessageEvent)->Void;
    public var state(default, never):String;
    public function open():js.Promise<MIDIInput>;
    public function close():js.Promise<MIDIInput>;
}

#end