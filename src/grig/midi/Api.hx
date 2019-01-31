package grig.midi;

// Ordered to match RtMidi to allow easy conversion
enum Api {
    Unspecified;
    MacOSCore;
    Alsa;
    Jack;
    WindowsMM;
    Dummy;
    Browser;
}