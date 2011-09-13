package national;

import RootClassesMapper;

@:hack class EReg extends RootPackage_EReg
{
    function ensureCharset()
    {
        untyped __call__('mb_regex_encoding', 'UTF-8');
    }
    
    public function new( r : String, opt : String)
    {
        super(r, opt);
        
        this.charset = charset;
    }
    
	override function split( s : String ) : Array<String> {
		ensureCharset();
        
        return untyped __php__("new _hx_array(mb_split($this->re, $s, $this->hglobal ? -1 : 2))");
	}
}