package;

import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import grig.midi.MidiOut;

import tink.core.Future;

class Main
{

    private static function mainLoop(midiIn:MidiIn)
    {
        #if (sys && !nodejs)
        var stdout = Sys.stdout();
        var stdin = Sys.stdin();
        // Using Sys.getChar() unfortunately fucks up the output
        stdout.writeString('quit[enter] to quit\n');
        while (true) {
            var command = stdin.readLine();
            if (command.toLowerCase() == 'quit') {
                midiIn.closePort();
                return;
            }
        }
        #end
    }

    static function main()
    {
        var midiIn = new MidiIn();
        midiIn.setCallback(function (midiMessage:MidiMessage, delta:Float) {
            trace(midiMessage.messageType);
            trace(delta);
        });
        midiIn.getPorts().handle(function(outcome) {
            switch outcome {
                case Success(ports):
                    trace(ports);
                    midiIn.openPort(0, 'grig.midi').handle(function(midiOutcome) {
                        switch midiOutcome {
                            case Success(_):
                                mainLoop(midiIn);
                            case Failure(error):
                                trace(error);
                        }
                    });
                case Failure(error):
                    trace(error);
            }
        });
    }

}
