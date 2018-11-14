package grig.midi.webmidi; #if (js && !nodejs)

@:native('Window')
class Window
{
    public var navigator(default,null):Navigator;
}

#end