package grig.midi;

typedef ListenCallback = (MidiMessage)->Void;

class MidiInPort
{
    private var listenCallbacks:Array<ListenCallback>;

    public function new()
    {
        listenCallbacks = new Array<ListenCallback>();
    }

    public function listen(callback:ListenCallback)
    {
        listenCallbacks.push(callback);
    }
}
