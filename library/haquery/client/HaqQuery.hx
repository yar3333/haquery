package haquery.client;

import js.JQuery;

class HaqQuery extends JQuery
{
    public var prefixCssClass : String;
    
    public function new(prefixCssClass:String, ?j:Dynamic)
    {
		this.prefixCssClass = prefixCssClass;
		super(j);
    }
	
	private function globalizeClassName(className:String) : String
	{
        var classes = (new EReg('\\s+', '')).split(className);
		return Lambda.map(classes, function(c) return prefixCssClass + c).join(' ');
	}
	
	override public function addClass(className:String) : JQuery 
	{
		return super.addClass(globalizeClassName(className));
	}
	
	override public function removeClass(className:String) : JQuery 
	{
		return super.removeClass(globalizeClassName(className));
	}
	
	override public function hasClass(className:String) : Bool 
	{
		return super.hasClass(globalizeClassName(className));
	}
}
