package grig.midi;

import haxe.io.Bytes;

enum MessageType {
    NoteOn;
    NoteOff;
    PolyPressure;
    Pressure;
    ControlChange;
    ProgramChange;
    Pitch;
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

    public function toBytes():Bytes
    {
        var bytes = Bytes.alloc(3);
        bytes.set(0, byte1);
        bytes.set(1, byte2);
        bytes.set(2, byte3);
        return bytes;
    }

    private function get_channel():Int
    {
        return (bytes & 0xf0000) >> 0x10;
    }

    public static function messageTypeForByte(byte:Int):MessageType
    {
        return switch (byte >> 0x04) {
            case 0x8: NoteOff;
            case 0x9: NoteOn;
            case 0xA: PolyPressure;
            case 0xB: ControlChange;
            case 0xC: ProgramChange;
            case 0xD: Pressure;
            case 0xE: Pitch;
            case 0xF: {
                switch (byte & 0xF) {
                    case 0x0: SysEx;
                    case 0x1: TimeCode;
                    case 0x2: SongPosition;
                    case 0x3: SongSelect;
                    case 0x6: TuneRequest;
                    case 0x8: TimeClock;
                    case 0xA: Start;
                    case 0xB: Continue;
                    case 0xC: Stop;
                    case 0xE: KeepAlive;
                    case 0xF: Reset;
                    default: Unknown;
                }
            }
            default: Unknown;
        }
    }

    private function get_messageType():MessageType
    {
        return messageTypeForByte(bytes >> 0x10);
    }

    public static function sizeForMessageType(messageType:MessageType):Int
    {
        return switch(messageType) {
            case NoteOn: 3;
            case NoteOff: 3;
            case PolyPressure: 3;
            case ControlChange: 3;
            case ProgramChange: 2;
            case Pressure: 2;
            case Pitch: 3;
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
                throw "Unknown midi message type: " + messageType;
            }
        }
    }

    private function get_size():Int
    {
        return sizeForMessageType(messageType);
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
