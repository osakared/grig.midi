package grig.midi.webmidi;

@:native('MIDIAccess')
extern class MIDIAccess
{
    var inputs:js.Map<String, MIDIInput>;
    var outputs:js.Map<String, MIDIOutput>;
}