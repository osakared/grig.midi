#ifndef RTMIDI_IN_HAXE_WRAPPER_H
#define RTMIDI_IN_HAXE_WRAPPER_H

#include "rtmidi.h"

namespace grig {

    typedef hx::ObjectPtr<grig::midi::cpp::rtmidi::MidiIn_obj> MidiInObject;
    void rtmidi_in_set_callback(RtMidiIn *rtMidiIn, MidiInObject midiIn);

}

#endif