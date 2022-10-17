package;

import grig.midi.file.event.ChannelPrefixEvent;
import grig.midi.file.event.PortPrefixEvent;
import haxe.io.BytesInput;
import haxe.Resource;
import grig.midi.MidiFile;
import tink.unit.Assert.*;

@:asserts
class MidiFileTest
{
    private var midiFile:MidiFile;

    public function new()
    {
        var bytes = Resource.getBytes('tests/bohemian_rhapsody.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
    }

    public function testNumTracks()
    {
        return assert(midiFile.tracks.length == 14);
    }

    public function testFirstBassNote()
    {
        for (midiEvent in midiFile.tracks[2].midiEvents) {
            switch (midiEvent.type) {
                case MidiMessage(messageEvent): {
                    if (messageEvent.midiMessage.messageType == NoteOn) {
                        var pitch = messageEvent.midiMessage.pitch;
                        asserts.assert(pitch.note == grig.pitch.PitchClass.D);
                        asserts.assert(pitch.octave == 5);
                        return asserts.done();
                    }
                }
                default:
                    continue;
            }
        }
        return asserts.done();
    }

    public function testWrite()
    {
        var output = new haxe.io.BytesOutput();
        midiFile.write(output);
        output.close();

        // // For manual testing.. won't work on targets without full sys implementation!
        // var fileOutput = sys.io.File.write('test.mid', true);
        // midiFile.write(fileOutput);
        // fileOutput.close();

        var bytes = output.getBytes();
        var newInput = new BytesInput(bytes);
        var newMidiFile = MidiFile.fromInput(newInput);
        for (midiEvent in newMidiFile.tracks[2].midiEvents) {
            switch (midiEvent.type) {
                case MidiMessage(messageEvent): {
                    if (messageEvent.midiMessage.messageType == NoteOn) {
                        return assert(messageEvent.midiMessage.byte2 == 0x3E);
                    }
                }
                default: continue;
            }            
        }
        return assert(false);
    }

    public function testFormat0()
    {
        var bytes = Resource.getBytes('tests/heart_of_glass.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        return assert(midiFile.tracks.length == 1 && midiFile.format == 0);
    }

    public function testFormat2()
    {
        var bytes = Resource.getBytes('tests/impmarch.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        return assert(midiFile.tracks.length == 2 && midiFile.format == 2);
    }

    public function testRunningStatus()
    {
        var bytes = Resource.getBytes('tests/asteroid_dance.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        return assert(midiFile.tracks[1].midiEvents.length == 1733);
    }

    public function testPortPrefixEvent()
    {
        var bytes = Resource.getBytes('tests/impmarch_anvil_channel_port_event.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        var matchingEvents = midiFile.tracks[0].midiEvents.filter(function(e){ return Std.isOfType(e, PortPrefixEvent);});
        var hasMatchingEventType = matchingEvents.length > 0;
        var hasCorrectEventValue = false;
        if (hasMatchingEventType) {
            hasCorrectEventValue = switch (matchingEvents[0].type) {
                case PortPrefix(portPrefixEvent): {
                    portPrefixEvent.portPrefix == 127;
                }
                default: false;
            }
            
        }
        return assert(hasMatchingEventType && hasCorrectEventValue);
    }

    public function testChannelPrefixEvent()
    {
        var bytes = Resource.getBytes('tests/impmarch_anvil_channel_port_event.mid');
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);
        var matchingEvents = midiFile.tracks[0].midiEvents.filter(function(e){ return Std.isOfType(e, ChannelPrefixEvent);});
        var hasMatchingEventType = matchingEvents.length > 0;
        var hasCorrectEventValue = false;
        if (hasMatchingEventType) {
            hasCorrectEventValue = switch (matchingEvents[0].type) {
                case ChannelPrefix(portPrefixEvent): portPrefixEvent.channelPrefix == 15;
                default: false;
            }
        }
        return assert(hasMatchingEventType && hasCorrectEventValue);
    }

}
