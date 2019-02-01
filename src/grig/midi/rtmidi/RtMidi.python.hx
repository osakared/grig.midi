package grig.midi.rtmidi;

@:pythonImport('rtmidi')
@:native('rtmidi')
extern class RtMidi
{
    @:native("get_compiled_api")
    static public function get_compiled_api():Array<Int>;
}