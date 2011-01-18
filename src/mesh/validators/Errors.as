package mesh.validators
{
	import collections.HashMap;
	
	import flash.utils.flash_proxy;
	
	import mesh.core.inflection.humanize;
	
	use namespace flash_proxy;
	
	/**
	 * A modified <code>HashMap</code> that includes utility methods for working with and storing
	 * validation errors.
	 * 
	 * @author Dan Schultz
	 */
	public class Errors extends HashMap
	{
		private var _host:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param host The object being validated that hosts the errors hash.
		 */
		public function Errors(host:Object)
		{
			super();
			_host = host;
		}
		
		/**
		 * Adds a new error message to the given property. This method allows you replace subsets
		 * of a string that have the format of <code>{key}</code>, where <code>key</code> is any 
		 * arbitrary string.
		 * 
		 * <listing version="3.0">
		 * trace(errors.add("property", "replacement 1: {key1}, replacement 2: {key1}", {key1:"a", key2:"b"})); // message is: "replacement 1: a, replacement 2: b"
		 * </listing>
		 * 
		 * @param property The property for the error message.
		 * @param message The error message.
		 * @param replacements A hash of keys to replace in the message.
		 */
		public function add(property:String, message:String, replacements:Object = null):void
		{
			for (var key:String in replacements) {
				message = message.replace("{" + key + "}", replacements[key]);
			}
			grab(property).push(message);
		}
		
		/**
		 * Iterates through each property and each error message of the property and calls a block
		 * function.  The block function should have the following signature:
		 * 
		 * <listing version="3.0">
		 * function(property:String, message:String):void
		 * {
		 * 	// do something
		 * }
		 * </listing>
		 * 
		 * @param block The function that is called for each property and message.
		 */
		public function forEach(block:Function):void
		{
			for each (var property:String in keys()) {
				for each (var error:String in grab(property)) {
					block(property, error);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function grab(key:Object):*
		{
			if (!containsKey(key)) {
				super.put(key, []);
			}
			return super.grab(key);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function put(key:Object, value:Object):*
		{
			return undefined;
		}
		
		/**
		 * Returns a flat array of errors messages, that also includes the property names at the
		 * beginning of each error message.
		 * 
		 * <listing version="3.0">
		 * errors.add("firstName", "can't be blank");
		 * errors.add("firstName", "must have more than 2 characters");
		 * trace(errors.toArray()); // ["first name can't be blank", "first name must have more than 2 characters"]
		 * </listing>
		 * 
		 * @return A flat array of error messages.
		 */
		public function toArray():Array
		{
			var result:Array = [];
			forEach(function(property:String, message:String):void
			{
				result.push(humanize(property).toLowerCase() + " " + message);
			});
			return result;
		}
		
		/**
		 * Returns a comma delimited list of all the errors.
		 * 
		 * @return All errors as a string.
		 */
		override public function toString():String
		{
			return toArray().toString();
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return grab(name.toString());
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			return add(name, value);
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iteratingItems = toArray();
				_len = _iteratingItems.length;
			}
			return index < _len ? index+1 : 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iteratingItems[index-1];
		}
		
		/**
		 * The number of error messages.
		 */
		override public function get length():int
		{
			return toArray().length;
		}
	}
}