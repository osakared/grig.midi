package grig.midi;

enum MessageType {
    NoteOn;
    NoteOff;
    PolyPressure;
    Pressure;
    ControlChange;
    ProgramChange;
    Pitch;
    Unknown;
}

class MidiMessage
{
    private var bytes:Int;

    public var messageType(get, never):MessageType;
    public var channel(get, never):Int;
    public var byte1(get, never):Int;
    public var byte2(get, never):Int;
    public var byte3(get, never):Int;

    public function new(_bytes:Int)
    {
        bytes = _bytes;
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
