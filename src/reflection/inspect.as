package reflection
{
	import functions.closure;
	
	import mx.utils.ObjectUtil;

	/**
	 * Returns a string that contains the name of the given object's class and the values for each
	 * of its fixed and dynamic properties.
	 * 
	 * @param obj The object to inspect.
	 * @return A string.
	 */
	public function inspect(obj:Object):String
	{
		if (ObjectUtil.isSimple(obj)) {
			return ObjectUtil.toString(obj);
		}
		
		var type:Type = reflect(obj);
		var properties:Array = type.properties.map(closure(function(property:Property):String
		{
			return property.name;
		}));
		
		for (var property:String in obj) {
			properties.push(property);
		}
		
		var result:String = "#<" + type.name;
		for (var key:String in properties.sort()) {
			result += " " + key + ": " + inspect(obj[key]);
		}
		
		return result + ">";
	}
}