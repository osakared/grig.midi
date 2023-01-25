package grig.midi;

import grig.pitch.Pitch;
import haxe.io.Bytes;

@:forward
abstract MidiMessage(Bytes)
{
    // public var bytes:Int;
    public var messageType(get, never):MessageType;
    public var controlChangeType(get, never):ControlChangeType;
    public var size(get, never):Int;
    public var channel(get, set):Int;
    public var byte1(get, set):Int;
    public var byte2(get, set):Int;
    public var byte3(get, set):Int;
    public var velocity(get, set):Int;
    public var last(get, set):Int;
    public var pitch(get, set):Pitch;

    public function new(bytes:Bytes) {
        this = bytes;
    }

    public static function ofBytesData(bytes:haxe.io.BytesData):MidiMessage {
        return new MidiMessage(Bytes.ofData(bytes));
    }

    public function getBytes():Bytes {
        return this;
    }

    /**
     * Converts array of 8-bit ints to a MidiMessage
     * @param array 
     * @return MidiMessage
     */
    public static function ofArray(array:Array<Int>):MidiMessage {
        var bytes = Bytes.alloc(array.length);
        for (i in 0...array.length) {
            bytes.set(i, array[i]);
        }
        return new MidiMessage(bytes);
    }

    private function get_channel():Int {
        return this.get(0) & 0xf;
    }

    private function set_channel(channel:Int):Int {
        this.set(0, this.get(0) | channel);
        return channel;
    }

    public static function ofMessageType(type:MessageType, values:Array<Int>, channel:Int = 0):MidiMessage {
        if (type != SysEx) {
            var messageSize = sizeForMessageType(type);
            var numValuesRequired = messageSize - 1;
            if (values.length != numValuesRequired){
                throw '$type requires $numValuesRequired values';
            }
        }
        if (channel < 0 || channel > 15) {
            throw 'Channel out of range';
        }
        var bytes:Array<Int> = [messageByteForType(type, channel)];
        if (values.length > 0) {
            for (v in values) {
                if (type != SysEx && !valueIsWithinRange(v)) {
                    throw 'Value out of range $v';
                }
                bytes.push(v);
            }
        }
        if (type == SysEx) {
            bytes.push(0xf7);
        }
        return ofArray(bytes);
    }

    private static function valueIsWithinRange(value:Int):Bool {
        return value >= 0 && value <= 127;
    }

    private static function messageByteForType(type:MessageType, channel:Int = 0):Int {
        var byte:Int = type;

        if (!type.isSysCommon()) {
            byte |= channel;
        }
        
        return byte;
    }

    private function get_messageType():MessageType {
        return MessageType.ofByte(this.get(0));
    }

    private function get_controlChangeType():ControlChangeType {
        if (MessageType.ofByte(this.get(0)) != MessageType.ControlChange) return NonControl;
        return ControlChangeType.ofByte(this.get(1));
    }

    public static function sizeForMessageType(messageType:MessageType):Int {
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
            case SysEx: {
                throw "Cannot determine length of sysex messages ahead of time";
            }
            case Unknown: {
                throw 'Unknown midi message type: $messageType';
            }
        }
    }

    private inline function get_size():Int {
        return this.length;
    }

    private inline function get_byte1():Int {
        return this.get(0);
    }

    private inline function set_byte1(val:Int):Int {
        this.set(0, val);
        return val;
    }

    private inline function get_byte2():Int {
        return this.get(1);
    }

    private inline function set_byte2(val:Int):Int {
        this.set(1, val);
        return val;
    }

    private inline function get_byte3():Int {
        return this.get(2);
    }

    private inline function set_byte3(val:Int):Int {
        this.set(2, val);
        return val;
    }

    private inline function get_velocity():Int {
        return this.get(2);
    }

    private inline function set_velocity(val:Int):Int {
        this.set(2, val);
        return val;
    }

    private inline function get_last():Int {
        return this.get(this.length - 1);
    }

    private inline function set_last(val:Int):Int {
        this.set(this.length - 1, val);
        return val;
    }

    private inline function get_pitch():Pitch {
        return Pitch.fromMidiNote(this.get(1));
    }

    private inline function set_pitch(pitch:Pitch):Pitch {
        this.set(1, pitch.toMidiNote());
        return pitch;
    }

    public function toArray():Array<Int> {
        var messageArray = new Array<Int>();
        for (i in 0...this.length) {
            messageArray.push(this.get(i));
        }
        return messageArray;
    }

    public function toString(asHex:Bool = false) {
        var message = [for(i in 0...this.length) asHex ? StringTools.hex(this.get(i)) : Std.string(this.get(i))].join(" ");
        return '[MidiMessage: $message]';
    }
}
