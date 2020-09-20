package grig.midi;

// Ordered to match RtMidi to allow easy conversion
enum abstract Api(Int)
{
    var Unspecified = 0;
    var MacOSCore = 1;
    var Alsa = 2;
    var Jack = 3;
    var WindowsMM = 4;
    var Dummy = 5;
    var RtMidiNumApis = 6;
    var Browser = 7;
}