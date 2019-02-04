package grig.midi;

enum TextEventType {
    Lyric;
    Marker;
    CuePoint;
}

class TextEvent
{
    public var text(default, null):String;
    public var absoluteTime(default, null):Int; // In ticks
    public var type(default, null):TextEventType;

    public function new(_text:String, _absoluteTime:Int, _type:TextEventType)
    {
        text = _text;
        absoluteTime = _absoluteTime;
        type = _type;
    }
}
