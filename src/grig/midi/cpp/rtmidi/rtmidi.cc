#include "rtmidi.h"

namespace grig {

    ::String stdStringToHaxeString(std::string &str)
    {
        return String(str.c_str(), str.size()).dup();
    }

    std::string haxeStringToStdString(String &str)
    {
        return std::string(str.utf8_str());
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

    RtMidiIn *rtmidi_in_create(int api, Array<::String> errors)
    {
        RtMidiIn *midiIn = nullptr;
        try {
            midiIn = new RtMidiIn((RtMidi::Api)api);
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

    void rtmidi_in_open_port(RtMidiIn *rtMidiIn, unsigned int port, ::String portName, Array<::String> errors)
    {
        try {
            rtMidiIn->openPort(port, haxeStringToStdString(portName));
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
    }

    void rtmidi_in_open_virtual_port(RtMidiIn *rtMidiIn, ::String portName, Array<::String> errors)
    {
        try {
            rtMidiIn->openVirtualPort(haxeStringToStdString(portName));
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
    }

    RtMidiOut *rtmidi_out_create(int api, Array<::String> errors)
    {
        RtMidiOut *midiOut = nullptr;
        try {
            midiOut = new RtMidiOut((RtMidi::Api)api);
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
            return nullptr;
        }
        return midiOut;
    }

    void rtmidi_out_destroy(RtMidiOut *rtMidiOut)
    {
        delete rtMidiOut;
    }

    Array<::String> rtmidi_out_get_port_names(RtMidiOut *rtMidiOut, Array<::String> errors)
    {
        auto portNames = Array_obj<::String>::__new();
        try {
            unsigned int count = rtMidiOut->getPortCount();
            for (unsigned int i = 0; i < count; ++i) {
                auto portName = rtMidiOut->getPortName(i);
                portNames->push(stdStringToHaxeString(portName));
            }
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
        return portNames;
    }

    void rtmidi_out_open_port(RtMidiOut *rtMidiOut, unsigned int port, ::String portName, Array<::String> errors)
    {
        try {
            rtMidiOut->openPort(port, haxeStringToStdString(portName));
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
    }

    void rtmidi_out_open_virtual_port(RtMidiOut *rtMidiOut, ::String portName, Array<::String> errors)
    {
        try {
            rtMidiOut->openVirtualPort(haxeStringToStdString(portName));
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
    }

    void rtmidi_out_send_message(RtMidiOut *rtMidiOut, Array<unsigned char> message, Array<::String> errors)
    {
        try {
            std::vector<unsigned char> outgoingMessage(message->length);
            for (size_t i = 0; i < message->length; ++i) {
                outgoingMessage[i] = message->__unsafe_get(i);
            }
            rtMidiOut->sendMessage(&outgoingMessage);
        } catch (RtMidiError &error) {
            errors->push(::String(error.what()));
        }
    }

}