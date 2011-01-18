package mesh.core.object
{
	import mesh.core.functions.closure;
	
	import mx.utils.ObjectUtil;
	import mesh.core.reflection.Property;
	import mesh.core.reflection.Type;
	import mesh.core.reflection.reflect;

	/**
	 * Returns a string that contains the name of the given object's class and the values for each
	 * of its fixed and dynamic properties.
	 * 
	 * @param obj The object to inspect.
	 * @return A string.
	 */
	public function inspect(obj:Object):String
	{
		if (obj == null) {
			return "null";
		}
		
		if (ObjectUtil.isSimple(obj)) {
			return ObjectUtil.toString(obj);
		}
		
		var type:Type = reflect(obj);
		var properties:Array = type.properties.map(closure(function(property:Property):String
		{
			return property.name;
		}));
		
		for (var key:String in obj) {
			properties.push(key);
		}
		
		var result:String = "#<" + type.name;
		for each (var property:String in properties.sort()) {
			result += ", " + property + ": " + inspect(obj[property]);
		}
		
		return result + ">";
	}
}