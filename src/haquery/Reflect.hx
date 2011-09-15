package haquery;

class Reflect
{
	/**
		Tells if an object has a field set. This doesn't take into account the object prototype (class methods).
	**/
    public static inline function hasField( o : Dynamic, field : String ) : Bool { return HaxeReflect.hasField(o, field); }

	/**
		Returns the field of an object, or null if [o] is not an object or doesn't have this field.
	**/
	public static inline function field( o : Dynamic, field : String ) : Dynamic { return HaxeReflect.field(o, field); }


	/**
		Set an object field value.
	**/
	public static inline function setField( o : Dynamic, field : String, value : Dynamic ) : Void { return HaxeReflect.setField(o, field, value); }

	/**
		Call a method with the given object and arguments.
	**/
	public static inline function callMethod( o : Dynamic, func : Dynamic, args : Array<Dynamic> ) : Dynamic { return HaxeReflect.callMethod(o, func, args); }

	/**
		Returns the list of fields of an object, excluding its prototype (class methods).
	**/
	public static inline function fields( o : Dynamic ) : Array<String> { return HaxeReflect.fields(o); }

	/**
		Tells if a value is a function or not.
	**/
	public static inline function isFunction( f : Dynamic ) : Bool { return HaxeReflect.isFunction(f); }

	/**
		Generic comparison function, does not work for methods, see [compareMethods]
	**/
	public static inline function compare<T>( a : T, b : T ) : Int { return HaxeReflect.compare(a, b); }

	/**
		Compare two methods closures. Returns true if it's the same method of the same instance.
	**/
	public static inline function compareMethods( f1 : Dynamic, f2 : Dynamic ) : Bool { return HaxeReflect.compareMethods(f1, f2); }

	/**
		Tells if a value is an object or not.

	**/
	public static inline function isObject( v : Dynamic ) : Bool { return HaxeReflect.isObject(v); }

	/**
		Delete an object field.
	**/
	public static inline function deleteField( o : Dynamic, f : String ) : Bool { return HaxeReflect.deleteField(o, f); }

	/**
		Make a copy of the fields of an object.
	**/
	public static inline function copy<T>( o : T ) : T { return HaxeReflect.copy(o); }

	/**
		Transform a function taking an array of arguments into a function that can
		be called with any number of arguments.
	**/
	public static inline function makeVarArgs( f : Array<Dynamic> -> Dynamic ) : Dynamic { return HaxeReflect.makeVarArgs(f); }
	
	public static function hasMethod( o : Dynamic, field : String ) : Bool
	{
        return (hasField(o, field) && isFunction(Reflect.field(o, field))); 
    }
}