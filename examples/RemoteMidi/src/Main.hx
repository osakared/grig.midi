package;

import grig.midi.OscMidiIn;
import grig.osc.UdpPacketListener;
import grig.osc.Server;
import sys.net.Host;

class Main
{
    public static function main()
    {
        var socket = new UdpPacketListener();
        socket.bind('127.0.0.1', 8000);
        var server = new Server(socket);
        var midiIn = new OscMidiIn();
        midiIn.setCallback((midiMessage:grig.midi.MidiMessage, delta:Float) -> {
            trace('${midiMessage.messageType} : $delta');
        });
        midiIn.listenToServer(server, '/midi');
        var stdout = Sys.stdout();
        var stdin = Sys.stdin();
        // Using Sys.getChar() unfortunately fucks up the output
        stdout.writeString('quit[enter] to quit\n');
        while (true) {
            var command = stdin.readLine();
            if (command.toLowerCase() == 'quit') {
                socket.close();
                return;
            }
        }
    }
}