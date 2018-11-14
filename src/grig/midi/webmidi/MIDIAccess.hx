package grig.midi.webmidi; #if (js && !nodejs)

@:native('MIDIAccess')
extern class MIDIAccess
{
    var inputs:js.Map<String, MIDIInput>;
    var outputs:js.Map<String, MIDIOutput>;
}

#end