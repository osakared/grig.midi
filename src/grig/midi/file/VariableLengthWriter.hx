package grig.midi.file;

import haxe.io.Output;

class VariableLengthWriter
{
    public static function writeVariableBytes(output:Output, value:Int, lengthToWrite:Null<Int> = null, dryRun:Bool = false):Int
    {
        var lengthWritten:Int = 0;

        var byte:Int = 0;
        var started:Bool = false;
        var shiftAmount:Int = 4; // Supporting at max 32-bit integers
        while(true) {
            byte = (value >> (7 * shiftAmount)) & 0x7f;
            shiftAmount -= 1;
            if (byte == 0 && !started && shiftAmount >= 0) continue;
            started = true;

            lengthWritten += 1;
            var isFinalByte:Bool = false;
            if (lengthToWrite != null) {
                if (lengthWritten > lengthToWrite) {
                    throw "Exceeded maximum write amount";
                }
                else if (lengthWritten == lengthToWrite) {
                    isFinalByte = true;
                }
            }
            else if (shiftAmount < 0) {
                isFinalByte = true;
            }

            if (!isFinalByte) {
                byte |= 0x80;
            }
            if (!dryRun) {
                output.writeByte(byte);
            }
            if (isFinalByte) {
                break;
            }
        }

        return lengthWritten;
    }
}