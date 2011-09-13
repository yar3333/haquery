package haquery;

@:hack class EReg extends HaxeEReg
{
    inline function ensureCharset()
    {
        untyped __call__('mb_regex_encoding', 'UTF-8');
    }
    
	public function splitNational( s : String ) : Array<String>
    {
		ensureCharset();
        return untyped __php__("new _hx_array(mb_split($this->re, $s, $this->hglobal ? -1 : 2))");
	}
}