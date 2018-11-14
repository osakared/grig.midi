package;

import grig.midi.MidiMessage;
import grig.midi.MidiOut;

import haxe.Timer;

import tink.core.Future;

class Main
{

    private static function mainLoop(midiOut:MidiOut)
    {
        var counter:Int = 0;
        var beatTimer = new Timer(500);
        var durationTimer = new Timer(5000);

        beatTimer.run = function() {
            midiOut.sendMessage(MidiMessage.fromArray(counter % 2 == 0 ? [144,54,70] : [128,54,64]));
            counter++;
        }

        durationTimer.run = function() {
            beatTimer.stop();
            durationTimer.stop();
        }

        #if (sys && !nodejs)
        var stdout = Sys.stdout();
        var stdin = Sys.stdin();
        // Using Sys.getChar() unfortunately fucks up the output
        stdout.writeString('quit[enter] to quit\n');
        while (true) {
            var command = stdin.readLine();
            if (command.toLowerCase() == 'quit') {
                midiOut.closePort();
                return;
            }
        }
        #end
    }

    static function main()
    {
        var midiOut = new MidiOut();
        midiOut.getPorts().handle(function(outcome) {
            switch outcome {
                case Success(ports):
                    trace(ports);
                    midiOut.openPort(0, 'grig.midi').handle(function(midiOutcome) {
                        switch midiOutcome {
                            case Success(_):
                                mainLoop(midiOut);
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
