#ifndef RTMIDI_HAXE_WRAPPER_H
#define RTMIDI_HAXE_WRAPPER_H

#ifndef HXCPP_H
#include <hxcpp.h>
#endif
#include "rtmidi/RtMidi.h"

namespace grig {

    Array<int> rtmidi_get_compiled_api();

    ::String stdStringToHaxeString(std::string &str);
    std::string haxeStringToStdString(String &str);

    typedef void(*GrigRtMidiCallback)(double timeStamp, Array<unsigned char> message, Dynamic userData);

    RtMidiIn *rtmidi_in_create(int api, Array<::String> errors);
    void rtmidi_in_destroy(RtMidiIn *rtMidiIn);
    Array<::String> rtmidi_in_get_port_names(RtMidiIn *rtMidiIn, Array<::String> errors);
    void rtmidi_in_open_port(RtMidiIn *rtMidiIn, unsigned int port, ::String portName, Array<::String> errors);
    void rtmidi_in_open_virtual_port(RtMidiIn *rtMidiIn, ::String portName, Array<::String> errors);

    RtMidiOut *rtmidi_out_create(int api, Array<::String> errors);
    void rtmidi_out_destroy(RtMidiOut *rtMidiOut);
    Array<::String> rtmidi_out_get_port_names(RtMidiOut *rtMidiOut, Array<::String> errors);
    void rtmidi_out_open_port(RtMidiOut *rtMidiOut, unsigned int port, ::String portName, Array<::String> errors);
    void rtmidi_out_open_virtual_port(RtMidiOut *rtMidiOut, ::String portName, Array<::String> errors);
    void rtmidi_out_send_message(RtMidiOut *rtMidiOut, Array<unsigned char> message, Array<::String> errors);

}

#endif
