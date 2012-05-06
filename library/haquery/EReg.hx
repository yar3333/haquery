package haquery;

@:hack class EReg extends std.EReg
{
	public function splitNational( s : String ) : Array<String>
    {
        untyped __call__('mb_regex_encoding', 'UTF-8');
        return untyped __php__("new _hx_array(mb_split($this->pattern, $s, $this->hglobal ? -1 : 2))");
	}
}