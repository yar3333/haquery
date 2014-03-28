package haquery.server;

#if (server || macro)

#if !macro

import Type;
import stdlib.Exception;
import stdlib.Std;
import stdlib.Debug;
import stdlib.FileSystem;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.common.HaqComponentTools;
import haxe.PosInfos;
import haxe.Serializer;
import haquery.common.Generated;
using stdlib.StringTools;

#end

@:allow(haquery.server)
@:autoBuild(haquery.macro.HaqComponentTools.build())
class HaqComponent extends haquery.base.HaqComponent
{
#if !macro
    
	/**
     * template.html as DOM tree.
     */
    var doc(default, null) : HtmlNodeElement;
    
    /**
     * HTML element, which contain this component.
     */
    var innerNode(default, null) : HtmlNodeElement;
    
	/**
	 * True for components declared inside another components (i.e. between tags (<haq:*>...</haq:*>).
	 */
	var isInnerComponent(default, null) : Bool;
	
    /**
     * These components was declared between <haq:*> and </haq:*> tags of this component.
     */
	var innerComponents : Array<HaqComponent>;
	
	/**
     * Need render?
     */
    public var visible : Bool;
    
	function new() : Void
	{
		super();
		
		innerComponents = [];
		visible = true;
	}
    
   	#if !fullCompletion @:noCompletion #end
	function construct(fullTag:String, parent:HaqComponent, id:String, doc:HtmlNodeElement, params:Dynamic, innerNode:HtmlNodeElement, isInnerComponent:Bool) : Void
    {
		Lib.profiler.begin("construct");
		
		super.commonConstruct(fullTag, parent, id);
		
		this.page = parent != null ? parent.page : cast this;
        this.doc = doc;
        this.innerNode = innerNode;
		this.isInnerComponent = isInnerComponent;
		
		if (params != null)
		{
			Lib.profiler.begin("loadFieldValues");
			loadFieldValues(params);
			Lib.profiler.end();
		}
        
		Lib.profiler.begin("createEvents");
		createEvents();
		Lib.profiler.end();
        
		Lib.profiler.begin("createChildComponents");
		createChildComponents();
		Lib.profiler.end();
		
		Lib.profiler.end();
    }
	
	#if !fullCompletion @:noCompletion #end
	function loadFieldValues(params:Dynamic) : Void
	{
		var fieldNames = HaqComponentTools.getFieldNamesToLoadParams(this);
		var paramNames = HaqComponentTools.getParamNames(params);
		
		for (fieldNameLC in fieldNames.keys())
		{
			var fieldName : String = null;
			var rawValue : Dynamic = null;
			
			if (paramNames.exists("get_" + fieldNameLC))
			{
				fieldName = fieldNames.get(fieldNameLC);
				rawValue = Reflect.callMethod(params, paramNames.get("get_" + fieldNameLC), []);
			}
			else
			if (paramNames.exists(fieldNameLC))
			{
				fieldName = fieldNames.get(fieldNameLC);
				rawValue = Reflect.field(params, paramNames.get(fieldNameLC));
			}
			
			if (fieldName != null)
			{
				var v : Dynamic;
				switch (Type.typeof(Reflect.field(this, fieldName)))
				{
					case ValueType.TInt:    v = Std.is(rawValue, Int) ? rawValue : Std.parseInt(rawValue);
					case ValueType.TFloat:  v = Std.is(rawValue, Float) ? rawValue : Std.parseFloat(rawValue);
					case ValueType.TBool:   v = Std.bool(rawValue);
					default:				v = rawValue;
				}
				Reflect.setField(this, fieldName, v);
			}
		}
	}
	
	#if !fullCompletion @:noCompletion #end
	function createChildComponents()
	{
		if (innerNode != null)
		{
			innerComponents = Lib.manager.createDocComponents(parent, innerNode, true);
		}
		
		if (doc != null)
		{
			Lib.manager.createDocComponents(this, doc, false);
		}
	}

	#if !fullCompletion @:noCompletion #end
    public function render() : String
    {
		if (!visible)
		{
			for (child in innerComponents)
			{
				child.visible = false;
			}
			
			return "";
		}
        
		return Lib.cache.get(getCacheID(), getCachePeriod(), function()
		{
			if (page.config.logSystemCalls) trace("HAQUERY render [" + fullID + "/" + fullTag + "]");
			var start = 0.0; if (page.config.logSlowSystemCalls >= 0) start = Sys.time();
			
			HaqComponentTools.expandDocElemIDs(prefixID, doc);
			if (parent != null && innerNode != null)
			{
				HaqComponentTools.expandDocElemIDs(parent.prefixID, innerNode);
			}
			
			for (child in innerComponents)
			{
				child.innerNode.parent.replaceChild(child.innerNode, new HtmlNodeText(child.render()));
			}
			
			for (child in components)
			{
				if (!child.isInnerComponent)
				{
					Debug.assert(child != null);
					Debug.assert(child.innerNode != null);
					Debug.assert(child.innerNode.parent != null);
					child.innerNode.parent.replaceChild(child.innerNode, new HtmlNodeText(child.render()));
				}
			}
			
			var text = doc.innerHTML;
			if (innerNode != null)
			{
				var reInnerContent = new EReg("<innercontent\\s*[/]>|<innercontent></innercontent>", "i");
				text = reInnerContent.replace(text, innerNode.innerHTML);
			}
			
			if (page.config.logSlowSystemCalls >= 0 && Sys.time() - start >= page.config.logSlowSystemCalls)
			{
				trace("HAQUERY SLOW: " + Std.string(Std.int((Sys.time() - start) * 1000)).lpad(" ", 5) + "  render [" + fullID + "/" + fullTag + "]" );
			}
			
			return text.trim(" \t\r\n");
		});
    }

    /**
     * Like $ в jQuery. Select DOM nodes from this component's DOM tree.
     * @param query CSS selector.
     */
    function q(?query:Dynamic=null) : HaqQuery
    {
		if (Type.getClass(query) == haquery.server.HaqQuery)
		{
			return query;
		}
		
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		if (query == null)
		{
			return new HaqQuery(page, prefixID, cssGlobalizer, '', null);
		}
		
		if (Type.getClass(query) == HtmlNodeElement)
		{
			Debug.assert(!page.isPostback, "Calling of the HaqComponent.q() with HtmlNodeElement parameter do not possible on the postback.");
			return new HaqQuery(page, prefixID, cssGlobalizer, "", [ query ]);
		}
		
		if (Std.is(query, Array))
		{
			Debug.assert(!page.isPostback, "Calling of the HaqComponent.q() with Array parameter do not possible on the postback.");
			return new HaqQuery(page, prefixID, cssGlobalizer, "", query);
		}
        
		if (Std.is(query, String))
		{
			
			var nodes = doc.find(cssGlobalizer.selector(query));
			return new HaqQuery(page, prefixID, cssGlobalizer, query, nodes);
		}
        
		throw new Exception("HaqComponent.q() error - 'query' parameter must be a String, HaqQuery or HtmlNodeElement.");
    }
	
	/**
	 * Delayed call client method, marked as @shared.
	 */
	#if !fullCompletion @:noCompletion #end
	function callSharedClientMethodDelayed(method:String, params:Array<Dynamic>) : Void
	{
		Debug.assert(page.isPostback, "HaqComponent.callSharedMethod() allowed on the postback only.");
        
        page.addAjaxResponse(
			  "page." + (fullID != "" ? "findComponent('" + fullID + "')." : "") + method
			+ "(" + Lambda.map(params != null ? params : [], function(p) return "haquery.client.HaqInternals.unserialize('" + Serializer.run(p) + "')").join(",") + ');'
		);
	}
    
	#if !fullCompletion @:noCompletion #end
	function callServerMethod(method:String, params:Array<Dynamic>, ?meta:String) : Dynamic
	{
		return HaqComponentTools.callMethod(this, method, params, meta);
	}
	
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	url Url to js file (global or related to support component folder).
	 * @example registerScript('myscript.js'); // assert file in support component folder
	 * @example registerScript('/scripts/myscript.js'); // site url
	 * @example registerScript('http://google.com/scripts/theirscript.js'); // global url
	 * @example registerScript('<script>alert("OK");</script>'); // html block
	 */
	function registerScript(url:String)
	{
		url = HaqComponentTools.getFullUrl(fullTag, url);
		if (!Lambda.has(page.registeredScripts, url))
		{
			page.registeredScripts.push(url);
		}
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	function registerStyle(url:String)
	{
		url = HaqComponentTools.getFullUrl(fullTag, url);
		if (!Lambda.has(page.registeredStyles, url))
		{
			page.registeredStyles.push(url);
		}
	}
	
	function getSupportPath() : String
	{
		return Lib.manager.get(fullTag).getSupportFilePath("");
	}
	
	/**
	 * Search for file (can search in "support" folders if relpath starts with "~/").
	 * @param	relpath File name or path (can starts with "~/").
	 * @return	Path to finded file or null if file not found.
	 */
	function resolveFilePath(relpath:String) : String
	{
		if (relpath.startsWith("~/"))
		{
			relpath = Lib.manager.get(fullTag).getSupportFilePath(relpath.substr(2));
		}
		else
		{
			if (!FileSystem.exists(relpath))
			{
				relpath = null;
			}
		}
		return relpath;
	}
	
	function getCacheID() : String return null;
	
	function getCachePeriod() return 0.0;

#end
	
	macro function template(ethis:haxe.macro.Expr)
	{
		return haquery.macro.HaqComponentTools.template(ethis);
	}
	
	macro function client(ethis:haxe.macro.Expr)
	{
		return haquery.macro.HaqComponentTools.shared(ethis);
	}
}

#end