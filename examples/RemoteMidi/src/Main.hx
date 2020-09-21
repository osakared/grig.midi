package;

import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import grig.midi.MidiOut;
import grig.midi.OscMidiIn;
import grig.midi.OscMidiOut;
import grig.osc.Client;
import grig.osc.Server;
import grig.osc.UdpPacketListener;
import grig.osc.UdpPacketSender;
import sys.net.Host;
import tink.core.Future;

enum Mode
{
    OscServerMode;
    OscClientMode;
    UnspecifiedMode;
}

enum ArgMode
{
    Host;
    Port;
    MidiDevice;
    Normal;
}

class Main
{
    private var socket:UdpPacketListener = null;
    private var host = '127.0.0.1';
    private var port = 8000;
    private var midiDevice = 0;

    private function startOscListener(midiOut:MidiOut):Void
    {
        socket = new UdpPacketListener();
        socket.bind(host, port);
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
        midiOut.openPort(midiDevice, 'grig.midi').handle(function(midiOutcome) {
            switch midiOutcome {
                case Success(_):
                    startOscListener(midiOut);
                case Failure(error):
                    trace(error);
            }
        });
    }

    private function startMidiInput(midiOut:OscMidiOut):Void
    {
        var midiIn = new MidiIn(grig.midi.Api.Unspecified);
        midiIn.setCallback(function (midiMessage:MidiMessage, delta:Float) {
            midiOut.sendMessage(midiMessage);
        });
        midiIn.openPort(midiDevice, 'grig.midi').handle(function(midiOutcome) {
            switch midiOutcome {
                case Success(_):
                case Failure(error):
                    trace(error);
            }
        });
    }

    private function startOscSender():Void
    {
        var sender = new UdpPacketSender(host, port);
        var client = new Client(sender);
        var midiOut = new OscMidiOut(client);
        startMidiInput(midiOut);
    }

    public function new()
    {
        var mode:Mode = UnspecifiedMode;
        var argMode:ArgMode = Normal;

        for (arg in Sys.args()) {
            switch argMode {
                case Normal:
                    if (arg == 'server') {
                        mode = OscServerMode;
                    } else if (arg == 'client') {
                        mode = OscClientMode;
                    } else if (arg == '--host' || arg == '-H') {
                        argMode = Host;
                    } else if (arg == '--port' || arg == '-P') {
                        argMode = Port;
                    } else if (arg == '--midi-device' || arg == '-M') {
                        argMode = MidiDevice;
                    }
                case Host:
                    host = arg;
                    argMode = Normal;
                case Port:
                    port = Std.parseInt(arg);
                    argMode = Normal;
                case MidiDevice:
                    midiDevice = Std.parseInt(arg);
                    argMode = Normal;
            }
        }

        switch (mode) {
            case OscServerMode:
                startMidiOutput();
            case OscClientMode:
                startOscSender();
            case UnspecifiedMode:
                trace('Must specify "server" or "client" mode to start');
                Sys.exit(1);
        }

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