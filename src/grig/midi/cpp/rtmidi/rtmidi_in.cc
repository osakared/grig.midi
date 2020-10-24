#include "rtmidi_in.h"

namespace grig {

    void grig_callback(double timeStamp, std::vector<unsigned char> *message, void *userData)
    {
        int base = 0;
        // Register thread to hxcpp's gc
        hx::SetTopOfStack(&base, true);

        auto midiIn = (grig::midi::cpp::rtmidi::MidiIn_obj *)userData;
        // We lose the memory efficiency of the rtmidi interface since we're copying message
        // into a new gc'd object, midiBytes.
        auto midiBytes = Array_obj<unsigned char>::__new();
        for (size_t i = 0; i < message->size(); ++i) {
            midiBytes->push((*message)[i]);
        }
        midiIn->midiCallback(timeStamp, midiBytes);
        
        hx::SetTopOfStack((int*)0, true);
    }

    void rtmidi_in_set_callback(RtMidiIn *rtMidiIn, MidiInObject midiIn)
    {
        rtMidiIn->setCallback(&grig_callback, (void *)midiIn.GetPtr());
    }

}