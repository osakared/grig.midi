package grig.midi;

enum abstract MessageType(Int) to Int
{
    var NoteOff = 0x80;
    var NoteOn = 0x90;
    var PolyPressure = 0xA0;
    var ControlChange = 0xB0;
    var ProgramChange = 0xC0;
    var Pressure = 0xD0;
    var Pitch = 0xE0;
    var SysEx = 0xF0;
    var TimeCode = 0xF1;
    var SongPosition = 0xF2;
    var SongSelect = 0xF3;
    var TuneRequest = 0xF6;
    var TimeClock = 0xF8;
    var Start = 0xFA;
    var Continue = 0xFB;
    var Stop = 0xFC;
    var KeepAlive = 0xFE;
    var Reset = 0xFF;
    var Unknown = 0;

    public inline function isSysCommon():Bool
    {
        return this >> 4 == 0xf;
    }

    public static function ofByte(byte:Int):MessageType
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
}