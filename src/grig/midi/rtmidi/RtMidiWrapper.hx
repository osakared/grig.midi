package grig.midi.rtmidi; #if cpp

@:build(grig.midi.rtmidi.Build.xml())
@:include('./rtmidi/rtmidi_c.h')

@:native('RtMidiWrapper')
@:structaccess
extern class RtMidiWrapper
{
    public var ok:Bool;
    public var msg:cpp.StdStringRef;
}

#end