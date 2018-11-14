package grig.midi.webmidi;

@:native('MIDIOutput')
extern class MIDIOutput
{
    public var name(default, never):String;
    public var state(default, never):String;
    public function send(data:Array<Int>, timestamp:Float = 0):Void;
    public function clear():Void;
    public function open():js.Promise<MIDIOutput>;
    public function close():js.Promise<MIDIOutput>;
}
