package grig.midi.file.event;

enum MidiFileEventType
{
    ChannelPrefix(event:ChannelPrefixEvent);
    EndTrack(event:EndTrackEvent);
    KeySignature(event:KeySignatureEvent);
    MidiMessage(event:MidiMessageEvent);
    PortPrefix(event:PortPrefixEvent);
    Sequence(event:SequenceEvent);
    SequencerSpecific(event:SequencerSpecificEvent);
    SmtpeOffset(event:SmtpeOffsetEvent);
    TempoChange(event:TempoChangeEvent);
    Text(event:TextEvent);
    TimeSignature(event:TimeSignatureEvent);
}
