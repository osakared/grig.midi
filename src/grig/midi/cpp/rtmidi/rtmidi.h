#ifndef RTMIDI_HAXE_WRAPPER_H
#define RTMIDI_HAXE_WRAPPER_H

#include <hxcpp.h>
#include "rtmidi/RtMidi.h"

namespace grig {

    typedef void(*GrigRtMidiCallback)(double timeStamp, Array<unsigned char> message, Dynamic userData);
    typedef hx::ObjectPtr<grig::midi::cpp::rtmidi::MidiIn_obj> MidiInObject;

    RtMidiIn *rtmidi_in_create(Array<::String> errors);
    void rtmidi_in_destroy(RtMidiIn *rtMidiIn);
    Array<int> rtmidi_get_compiled_api();
    Array<::String> rtmidi_in_get_port_names(RtMidiIn *rtMidiIn, Array<::String> errors);
    void rtmidi_in_open_port(RtMidiIn *rtMidiIn, unsigned int port, Array<::String> errors);
    void rtmidi_in_set_callback(RtMidiIn *rtMidiIn, MidiInObject midiIn);

}

#endif