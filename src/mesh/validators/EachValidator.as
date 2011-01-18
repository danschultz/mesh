package mesh.validators
{
	

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
		override public function validate(obj:Object):void
		{
			for each (var property:String in properties) {
				validateProperty(obj, property, obj[property]);
			}
		}
		
		/**
		 * Called by <code>validate()</code> to validate a single property on an object. This
		 * method is intended to be overridden by sub-classes to run the validation.
		 * 
		 * @param obj The object being validated.
		 * @param property The property to validate.
		 * @param value The object's property value.
		 */
		protected function validateProperty(obj:Object, property:String, value:Object):void
		{
			
		}
		
		/**
		 * The properties that the validator is evaluating, as a list of <code>String</code>s.
		 */
		protected function get properties():Array
		{
			if (options.hasOwnProperty("properties")) {
				return options.properties;
			}
			return [options.property];
		}
	}
}