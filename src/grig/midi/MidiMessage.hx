package grig.midi;

enum MessageType {
    NoteOn;
    NoteOff;
    PolyPressure;
    Pressure;
    ControlChange;
    ProgramChange;
    Pitch;
    ChannelMode;
    SysEx;
    TimeCode;
    SongPosition;
    SongSelect;
    TuneRequest;
    TimeClock;
    Start;
    Continue;
    Stop;
    KeepAlive;
    Reset;
    Unknown;
}

class MidiMessage
{
    public var bytes(default, null):Int;
    public var messageType(get, never):MessageType;
    public var size(get, never):Int;
    public var channel(get, never):Int;
    public var byte1(get, never):Int;
    public var byte2(get, never):Int;
    public var byte3(get, never):Int;

    public function new(_bytes:Int)
    {
        bytes = _bytes;
    }

    public static function fromArray(_bytes:Array<Int>):MidiMessage
    {
        var bytes:Int = 0;
        var i = 1;
        for (byte in _bytes) {
            bytes += byte << (_bytes.length - i) * 8;
            i++;
        }

        return new MidiMessage(bytes);
    }

    public function toArray():Array<Int>
    {
        var array = new Array<Int>();
        array.push(byte1);
        array.push(byte2);
        array.push(byte3);
        return array;
    }

    private function get_channel():Int
    {
        return (bytes & 0xf0000) >> 0x10;
    }

    private function get_messageType():MessageType
    {
        return switch ((bytes & 0xf00000) >> 0x14) {
            case 8:  NoteOff;
            case 9:  NoteOn;
            case 10: PolyPressure;
            case 11: ControlChange;
            case 12: ProgramChange;
            case 13: Pressure;
            case 14: Pitch;
            default: Unknown;
        }
    }

    private function get_size():Int
    {
        return switch(messageType) {
            case NoteOn: 3;
            case NoteOff: 3;
            case PolyPressure: 3;
            case ControlChange: 3;
            case ProgramChange: 2;
            case Pressure: 2;
            case Pitch: 3;
            case ChannelMode: 3;
            case TimeCode: 2;
            case SongPosition: 3;
            case SongSelect: 2;
            case TuneRequest: 1;
            case TimeClock: 1;
            case Start: 1;
            case Continue: 1;
            case Stop: 1;
            case KeepAlive: 1;
            case Reset: 1;
            default: { // includes SysEx, which shouldn't be deserialized as a MidiMessage anyway, and undefineds
                throw "Unknown midi message type";
            }
        }
    }

    private function get_byte1():Int
    {
        return (bytes & 0xff0000) >> 0x10;
    }

    private function get_byte2():Int
    {
        return (bytes & 0xff00) >> 8;
    }

    private function get_byte3():Int
    {
        return (bytes & 0xff);
    }
}
