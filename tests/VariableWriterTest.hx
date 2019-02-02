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
        var nums = [12, 567, 1028, 0];
        var outputNums = [];
        for (num in nums) {
            var output = new BytesOutput();
            output.writeVariableBytes(num);
            output.close();
            var input = new BytesInput(output.getBytes());
            var variableBytes = input.readVariableBytes();
            outputNums.push(variableBytes.value);
        }
        return [for (i in 0...nums.length) assert(nums[i] == outputNums[i])];
    }

}
