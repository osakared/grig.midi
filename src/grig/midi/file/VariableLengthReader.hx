package grig.midi.file;

import haxe.io.Input;

typedef VariableBytes = {
    var value:Int;
    var length:Int;
}

class VariableLengthReader
{
    public static function readVariableBytes(input:Input):VariableBytes
    {
        var length:Int = 0;
        var value:Int = input.readByte();
        length += 1;

        if (value & 0x80 != 0) {
            value = value & 0x7F;
            while(true) {
                var newByte = input.readByte();
                length += 1;
                value = (value << 7) + (newByte & 0x7F);
                if (newByte & 0x80 == 0) {
                    break;
                }
            }
        }

        return { value: value, length: length };
    }
}