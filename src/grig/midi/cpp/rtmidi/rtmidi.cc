#include "rtmidi.h"

namespace grig {

    ::String stdStringToHaxeString(std::string &str)
    {
        return String(str.c_str(), str.size()).dup();
    }

    RtMidiIn *rtmidi_in_create(Array<::String> errors)
    {
        RtMidiIn *midiIn = nullptr;
        try {
            midiIn = new RtMidiIn();
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
            return nullptr;
        }
        return midiIn;
    }

    void rtmidi_in_destroy(RtMidiIn *rtMidiIn)
    {
        delete rtMidiIn;
    }

    Array<int> rtmidi_get_compiled_api()
    {
        auto apiInts = Array_obj<int>::__new();
        std::vector<RtMidi::Api> apis;
        RtMidi::getCompiledApi(apis);
        for (size_t i = 0; i < apis.size(); ++i) {
            apiInts->push(apis[i]);
        }
        return apiInts;
    }

    Array<::String> rtmidi_in_get_port_names(RtMidiIn *rtMidiIn, Array<::String> errors)
    {
        auto portNames = Array_obj<::String>::__new();
        try {
            unsigned int count = rtMidiIn->getPortCount();
            for (unsigned int i = 0; i < count; ++i) {
                auto portName = rtMidiIn->getPortName(i);
                portNames->push(stdStringToHaxeString(portName));
            }
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
        return portNames;
    }

    void rtmidi_in_open_port(RtMidiIn *rtMidiIn, unsigned int port, Array<::String> errors)
    {
        try {
            rtMidiIn->openPort(port, "grig midi input");
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
    }

    void grig_callback(double timeStamp, std::vector<unsigned char> *message, void *userData)
    {
        auto midiIn = (grig::midi::cpp::rtmidi::MidiIn_obj*)userData;
        midiIn->midiCallback(timeStamp);
    }

    void rtmidi_in_set_callback(RtMidiIn *rtMidiIn, MidiInObject midiIn)
    {
        rtMidiIn->setCallback(&grig_callback, (void *)midiIn.GetPtr());
    }

}