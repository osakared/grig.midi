package grig.midi.cpp.rtmidi;
  
import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Build
{
    private static function addCoreFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-D__MACOSX_CORE__');

        var coreServices = Xml.createElement('vflag');
        coreServices.set('name', '-framework');
        coreServices.set('value', 'CoreServices');

        var coreAudio = Xml.createElement('vflag');
        coreAudio.set('name', '-framework');
        coreAudio.set('value', 'CoreAudio');

        var coreMIDI = Xml.createElement('vflag');
        coreMIDI.set('name', '-framework');
        coreMIDI.set('value', 'CoreMIDI');

        var coreFoundation = Xml.createElement('vflag');
        coreFoundation.set('name', '-framework');
        coreFoundation.set('value', 'CoreFoundation');

        var wlFlags = Xml.createElement('flag');
        wlFlags.set('value', '-Wl,-F/Library/Frameworks');

        for (flag in [defineXml]) {
            flag.set('if', 'macos || ios');
            files.addChild(flag);
        }

        for (flag in [coreServices, coreAudio, coreMIDI, coreFoundation, wlFlags]) {
            flag.set('if', 'macos || ios');
            target.addChild(flag);
        }
    }

    private static function addALSAFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-D__LINUX_ALSA__');

        var libALSA = Xml.createElement('lib');
        libALSA.set('name', '-lasound');

        for (flag in [defineXml]) {
            flag.set('if', 'linux'); // What do I do about FreeBSD?
            files.addChild(flag);
        }

        for (flag in [libALSA]) {
            flag.set('if', 'linux');
            target.addChild(flag);
        }
    }

    // Dynamically linking and not statically building a la rtmidi itself because lGPL
    private static function addJACKFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-D__UNIX_JACK__');

        var libJACK = Xml.createElement('lib');
        libJACK.set('name', '-ljack');

        for (flag in [defineXml]) {
            flag.set('if', 'enable_jack');
            files.addChild(flag);
        }

        for (flag in [libJACK]) {
            flag.set('if', 'enable_jack');
            target.addChild(flag);
        }
    }

    private static function addWinMMFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-D__WINDOWS_MM__');

        var libJACK = Xml.createElement('lib');
        libJACK.set('name', 'winmm.lib');

        for (flag in [defineXml]) {
            flag.set('if', 'windows');
            files.addChild(flag);
        }

        for (flag in [libJACK]) {
            flag.set('if', 'windows');
            target.addChild(flag);
        }
    }

    macro public static function xml():Array<Field>
    {
        var _pos =  Context.currentPos();
        var _pos_info = _pos.getInfos();
        var _class = Context.getLocalClass();

        var _source_path = Path.directory(_pos_info.file);
        if( !Path.isAbsolute(_source_path) ) {
            _source_path = Path.join([Sys.getCwd(), _source_path]);
        }

        _source_path = Path.normalize(_source_path);

        var _lib_path = Path.normalize(Path.join([_source_path, 'rtmidi']));

        var _xml = Xml.createDocument();
        var _topElement = Xml.createElement('xml');
        _xml.addChild(_topElement);

        var rtmidiFiles = 'rtmidi-files';
        var _files = Xml.createElement('files');
        _files.set('id', rtmidiFiles);
        _files.set('dir', _source_path);
        for (fileName in [Path.join(['rtmidi', 'RtMidi.cpp']), 'rtmidi.cc']) {
            var _file = Xml.createElement('file');
            _file.set('name', fileName);
            _files.addChild(_file);
        }
        _topElement.addChild(_files);

        var _haxeTarget = Xml.createElement('target');
        _haxeTarget.set('id', 'haxe');
        _haxeTarget.set('tool', 'linker');
        _haxeTarget.set('toolid', '$${haxelink}');
        _haxeTarget.set('output', '$${HAXE_OUTPUT_FILE}');
        var _libXml = Xml.createElement('lib');
        _libXml.set('name', Path.normalize(Path.join(['build', 'librtmidi$${LIBEXT}'])));
        var _targetDependency = Xml.createElement('target');
        _targetDependency.set('id', 'rtmidi-link');
        _haxeTarget.addChild(_libXml);
        _haxeTarget.addChild(_targetDependency);
        _topElement.addChild(_haxeTarget);

        var _defaultTarget = Xml.createElement('target');
        _defaultTarget.set('id', 'rtmidi-link');
        _defaultTarget.set('tool', 'linker');
        _defaultTarget.set('toolid', 'static_link');
        _defaultTarget.set('output', 'librtmidi');
        var _filesRef = Xml.createElement('files');
        _filesRef.set('id', rtmidiFiles);
        var _outdir = Xml.createElement('outdir');
        _outdir.set('name', 'build');
        _defaultTarget.addChild(_filesRef);
        _defaultTarget.addChild(_outdir);
        _topElement.addChild(_defaultTarget);

        addCoreFlags(_files, _haxeTarget);
        addALSAFlags(_files, _haxeTarget);
        addJACKFlags(_files, _haxeTarget);
        addWinMMFlags(_files, _haxeTarget);

        var filesString = _files.toString();
        var haxeTargetString = _haxeTarget.toString();
        var defaultTargetString = _defaultTarget.toString();

        _class.get().meta.add(":buildXml", [{ expr:EConst( CString( '$filesString\n$haxeTargetString\n$defaultTargetString' ) ), pos:_pos }], _pos );

        return Context.getBuildFields();
    }

}