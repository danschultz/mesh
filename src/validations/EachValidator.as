package validations
{
	import collections.ArraySet;

	/**
	 * A validator base class that will validate a set of properties on the same 
	 * object.
	 * 
	 * @author Dan Schultz
	 */
	public class EachValidator extends Validator
	{
		/**
		 * @copy Validator#Validator()
		 */
		public function EachValidator(options:Object)
		{
			super(options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function validate(obj:Object):Array
		{
			var errors:Array = [];
			for each (var property:String in properties) {
				var error:Object = validateProperty(obj, property, obj[property]);
				if (error is ValidationError) {
					errors.push(error);
				}
			}
			return errors;
		}
		
		/**
		 * Called by <code>validate()</code> to validate a single property on an object. This
		 * method is intended to be overridden by sub-classes to run the validation.
		 * 
		 * @param obj The object being validated.
		 * @param property The property to validate.
		 * @param value The object's property value.
		 * @return A <code>ValidationError</code> if the validation fails.
		 */
		protected function validateProperty(obj:Object, property:String, value:Object):Object
		{
			return passed();
		}
		
		/**
		 * The properties that the validator is evaluating, as a list of <code>String</code>s.
		 */
		protected function get properties():Array
		{
			var result:ArraySet = new ArraySet();
			
			if (options.hasOwnProperty("properties")) {
				result.addAll(options.properties);
			}
			
			if (options.hasOwnProperty("property")) {
				result.add(options.property);
			}
			
			return result.toArray();
		}
	}
}