package;

using grig.midi.VariableLengthReader;
using grig.midi.VariableLengthWriter;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import tink.unit.Assert.*;

@:asserts
class VariableWriterTest
{
    public function new()
    {
    }

    public function testWriteAndRead()
    {
        var numsWritten = [12, 567, 1028, 0];
        var numsRead = new Array<Int>();
        var lengthsWritten = new Array<Int>();
        var lengthsRead = new Array<Int>();
        for (num in numsWritten) {
            var output = new BytesOutput();
            var written = output.writeVariableBytes(num);
            lengthsWritten.push(written);
            output.close();
            var input = new BytesInput(output.getBytes());
            var variableBytes = input.readVariableBytes();
            numsRead.push(variableBytes.value);
            lengthsRead.push(variableBytes.length);
        }
        // return [for (i in 0...numsWritten.length) assert(numsWritten[i] == numsRead[i])];
        return [for (i in 0...lengthsWritten.length) assert(lengthsWritten[i] == lengthsRead[i])];
    }

}
