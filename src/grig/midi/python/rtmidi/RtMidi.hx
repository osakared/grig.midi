package grig.midi.python.rtmidi;

@:pythonImport('rtmidi')
@:native('rtmidi')
extern class RtMidi
{
    @:native("get_compiled_api")
    static public function get_compiled_api():Array<grig.midi.Api>;
}