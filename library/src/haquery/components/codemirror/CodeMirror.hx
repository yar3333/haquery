package haquery.components.codemirror;

import js.Dom;

typedef CodeMirrorInitParams = {
    var mode : String;
    var indentUnit : Int;
    var value : String;
    var readOnly : Bool;
    var onChange : Void->Void;
    var saveFunction : Void->Void;
}

@:native('CodeMirror') extern class CodeMirror 
{
    static inline function create(elem:HtmlDom, params:CodeMirrorInitParams) : CodeMirror
    {
        return untyped CodeMirror(elem, params);
    }
    
    public function getValue() : String;
    public function setValue(text:String) : Void; 
    public function focus() : Void;
    public function refresh() : Void;
    public function getWrapperElement() : HtmlDom;
}