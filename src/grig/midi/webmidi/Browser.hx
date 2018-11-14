package grig.midi.webmidi; #if (js && !nodejs)

class Browser
{
    public static var window(get, never):Window;
    extern inline static function get_window() return untyped __js__("window");
}

#end