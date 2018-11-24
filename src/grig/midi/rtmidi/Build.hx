package grig.midi.rtmidi;
  
import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Build
{

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
        _files.set('dir', _lib_path);
        var _file = Xml.createElement('file');
        _file.set('name', 'RtMidi.cpp');
        _files.addChild(_file);
        _topElement.addChild(_files);

        var _target = Xml.createElement('target');
        _target.set('id', 'haxe');
        _target.set('tool', 'linker');
        _target.set('toolid', '$${haxelink}');
        _target.set('output', '$${HAXE_OUTPUT_FILE}');
        var _filesRef = Xml.createElement('files');
        _filesRef.set('id', rtmidiFiles);
        _target.addChild(_filesRef);
        _topElement.addChild(_target);

        var filesString = _files.toString();
        var targetString = _target.toString();

        _class.get().meta.add(":buildXml", [{ expr:EConst( CString( '$filesString\n$targetString' ) ), pos:_pos }], _pos );

        return Context.getBuildFields();
    }

}