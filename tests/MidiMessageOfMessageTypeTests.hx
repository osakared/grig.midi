package;

import grig.midi.MidiMessage;
import grig.midi.MidiMessage.MessageType;
import tink.unit.Assert.*;

@:asserts
class MidiMessageOfMessageTypeTests
{

    public function new() {}
    @:variant([], true)
    @:variant([0], true)
    @:variant([0, 0, 0], true)
    @:variant([0, 0], false)

    public function validateTwoValues(values:Array<Int>, shouldThrow:Bool)
    {
        var expectedException = shouldThrow ? "NoteOff requires 2 values" : "";
        var thrownException = "";
        var wasThrown = false;
        try {
            var midiMessage = MidiMessage.ofMessageType(NoteOff, values);
        }
        catch(e) {
            thrownException = e.message;
            wasThrown = true;
            trace(e.message);
        }
        return assert(wasThrown == shouldThrow && thrownException == expectedException);
    }

    @:variant([], true)
    @:variant([0, 0], true)
    @:variant([0, 0, 0], true)
    @:variant([0], false)
    public function validateOneValue(values:Array<Int>, shouldThrow:Bool)
    {
        var expectedException = shouldThrow ? "ProgramChange requires 1 values" : "";
        var thrownException = "";
        var wasThrown = false;
        try {
            var midiMessage = MidiMessage.ofMessageType(ProgramChange, values);
        }
        catch(e) {
            thrownException = e.message;
            wasThrown = true;
            trace(e.message);
        }
        return assert(wasThrown == shouldThrow && thrownException == expectedException);
    }

    
    @:variant([0], true)
    @:variant([0, 0], true)
    @:variant([0, 0, 0], true)
    @:variant([], false)
    public function validateZeroValues(values:Array<Int>, shouldThrow:Bool)
    {
        var expectedException = shouldThrow ? "TuneRequest requires 0 values" : "";
        var thrownException = "";
        var wasThrown = false;
        try {
            var midiMessage = MidiMessage.ofMessageType(TuneRequest, values);
        }
        catch(e) {
            thrownException = e.message;
            wasThrown = true;
            trace(e.message);
        }
        return assert(wasThrown == shouldThrow && thrownException == expectedException);
    }

    @:variant(ProgramChange, [-1])
    @:variant(ProgramChange, [128])
    @:variant(NoteOff, [-1, -1])
    @:variant(NoteOff, [128, 128])
    public function requireValue1WithinRange(type:MessageType, values:Array<Int>)
    {
        var exceptionWasThrown = false;
        var exceptionMessage = "";
        try {
            var midiMessage = MidiMessage.ofMessageType(type, values);
        }
        catch(e) {
            exceptionMessage = e.message;
            exceptionWasThrown = true;
            trace(e.message);
        }
        return assert(exceptionWasThrown == true && StringTools.startsWith(exceptionMessage,"Value out of range"));
    }
    
    @:variant(-1)
    @:variant(16)
    public function requireChannelWithinRange(channel:Int)
    {
        var exceptionMessage = "";
        var exceptionWasThrown = false;
        try {
            var midiMessage = MidiMessage.ofMessageType(MessageType.ProgramChange, [0], channel);
        }
        catch(e) {
            exceptionMessage = e.message;
            exceptionWasThrown = true;
            trace(e.message);
        }
        return assert(exceptionWasThrown == true && exceptionMessage == "Channel out of range");
    }

    function messageTypeFromByte(byte:Int):Int
    {
        return byte >> 0x4;
    }

    function channelFromByte(byte:Int):Int
    {
        return byte & 0xf;
    }

    @:variant(0)
    @:variant(1)
    @:variant(2)
    @:variant(3)
    @:variant(4)
    @:variant(5)
    @:variant(6)
    @:variant(7)
    @:variant(8)
    @:variant(9)
    @:variant(10)
    @:variant(11)
    @:variant(12)
    @:variant(13)
    @:variant(14)
    @:variant(15)
    public function testOfMessageType_Byte1_Channel(channel:Int)
    {
        var midiMessage = MidiMessage.ofMessageType(MessageType.NoteOn, [0, 0], channel);
        var statusByteMessageChannel = channelFromByte(midiMessage.byte1);
        return assert(statusByteMessageChannel == channel);
    }

    public function testOfMessageType_3Bytes_Byte2()
    {
        var note = 42;
        var velocity = 0;
        var midiMessage = MidiMessage.ofMessageType(MessageType.NoteOn, [note, velocity]);
        return assert(midiMessage.byte2 == note);
    }
    
    public function testOfMessageType_3Bytes_Byte3()
    {
        var note = 0;
        var velocity = 64;
        var midiMessage = MidiMessage.ofMessageType(MessageType.NoteOn, [note, velocity]);
        return assert(midiMessage.byte3 == velocity);
    }

    public function testOfMessageType_2Bytes_Byte2()
    {
        var program = 127;
        var midiMessage = MidiMessage.ofMessageType(MessageType.ProgramChange, [program]);
        return assert(midiMessage.byte2 == program);
    }

    @:variant(NoteOff)
    @:variant(NoteOn)
    @:variant(PolyPressure)
    @:variant(ControlChange)
    @:variant(Pitch)
    public function testOfMessageType_3Bytes_Type(expectedType:MessageType)
    {
        var midiMessage = MidiMessage.ofMessageType(expectedType, [0, 0]);
        var returnedType = MidiMessage.messageTypeForByte(midiMessage.byte1);
        return assert(expectedType == returnedType);
    }

    @:variant(ProgramChange)
    @:variant(Pressure)
    public function testOfMessageType_2Bytes_Type(expectedType:MessageType)
    {
        var midiMessage = MidiMessage.ofMessageType(expectedType, [0]);
        var returnedType = MidiMessage.messageTypeForByte(midiMessage.byte1);
        return assert(expectedType == returnedType);
    }

    function constructSysExByte(byte:Int):Int
    {
        return 0xF << 0x4 | byte;
    }

    @:variant(SysEx, 0x0)
    @:variant(TimeCode, 0x1)
    @:variant(SongPosition, 0x2)
    @:variant(SongSelect, 0x3)
    @:variant(TuneRequest, 0x6)
    @:variant(TimeClock, 0x8)
    @:variant(Start, 0xA)
    @:variant(Continue, 0xB)
    @:variant(Stop, 0xC)
    @:variant(KeepAlive, 0xE)
    @:variant(Reset, 0xF)
    public function sysexMessageTypes(type:MessageType, byte:Int)
    {
        var sysex = constructSysExByte(byte);
        var returnedType = MidiMessage.messageTypeForByte(sysex);
        return assert(type == returnedType);
    }

    // @:variant(SysEx) todo ?
    // @:variant(Unknown) todo ?
    @:variant(TuneRequest)
    @:variant(TimeClock)
    @:variant(Start)
    @:variant(Continue)
    @:variant(Stop)
    @:variant(KeepAlive)
    @:variant(Reset)
    public function testOfMessageType_SysEx_1Bytes_Type(expectedType:MessageType)
    {
        var midiMessage:MidiMessage = null;
        try {
             midiMessage = MidiMessage.ofMessageType(expectedType, []);
        }
        catch(e) {
            trace(e.message);
        }
        var sysExByte = constructSysExByte(midiMessage.byte1);
        var returnedType = MidiMessage.messageTypeForByte(sysExByte);
        return assert(expectedType == returnedType);
    }

    @:variant(TimeCode)
    @:variant(SongSelect)
    public function testOfMessageType_SysEx_2Bytes_Type(expectedType:MessageType)
    {
        var midiMessage:MidiMessage = null;
        try{
             midiMessage = MidiMessage.ofMessageType(expectedType, [0]);
        }
        catch(e){
            trace(e.message);
        }
        var sysExByte = constructSysExByte(midiMessage.byte1);
        var returnedType = MidiMessage.messageTypeForByte(sysExByte);
        return assert(expectedType == returnedType);
    }

    @:variant(SongPosition)
    public function testOfMessageType_SysEx_3Bytes_Type(expectedType:MessageType)
    {
        var midiMessage:MidiMessage = null;
        try{
             midiMessage = MidiMessage.ofMessageType(expectedType, [0, 0]);
        }
        catch(e){
            trace(e.message);
        }
        var sysExByte = constructSysExByte(midiMessage.byte1);
        var returnedType = MidiMessage.messageTypeForByte(sysExByte);
        return assert(expectedType == returnedType);
    }
}
