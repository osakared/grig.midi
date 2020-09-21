package;

import grig.midi.MidiOut;
import grig.midi.OscMidiIn;
import grig.osc.UdpPacketListener;
import grig.osc.Server;
import sys.net.Host;
import tink.core.Future;

class Main
{
    private var socket:UdpPacketListener = null;

    private function startOscListener(midiOut:MidiOut):Void
    {
        socket = new UdpPacketListener();
        socket.bind('127.0.0.1', 8000);
        var server = new Server(socket);
        var midiIn = new OscMidiIn();
        midiIn.setCallback((midiMessage:grig.midi.MidiMessage, delta:Float) -> {
            midiOut.sendMessage(midiMessage);
        });
        midiIn.listenToServer(server, '/midi');
    }

    private function startMidiOutput():Void
    {
        var midiOut = new MidiOut(grig.midi.Api.Unspecified);
        midiOut.openPort(0, 'grig.midi').handle(function(midiOutcome) {
            switch midiOutcome {
                case Success(_):
                    startOscListener(midiOut);
                case Failure(error):
                    trace(error);
            }
        });
    }

    public function new()
    {
        startMidiOutput();

        var stdout = Sys.stdout();
        var stdin = Sys.stdin();
        // Using Sys.getChar() unfortunately fucks up the output
        stdout.writeString('quit[enter] to quit\n');
        while (true) {
            var command = stdin.readLine();
            if (command.toLowerCase() == 'quit') {
                if (socket != null) socket.close();
                return;
            }
        }
    }

    public static function main()
    {
        var m = new Main();
    }
}