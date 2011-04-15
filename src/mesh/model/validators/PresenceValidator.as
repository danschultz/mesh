package mesh.model.validators
{
	import mesh.core.object.isEmpty;

	/**
	 * The presence validator ensures that a property is populated, that a string is not empty 
	 * or only contains whitespace, and that a number is not NaN. If the property being validated 
	 * contains an isEmpty property or method, that result will be used for evaluation.
	 * 
	 * @author Dan Schultz
	 */
	public class PresenceValidator extends EachValidator
	{
		/**
		 * @copy Validator#Validator()
		 */
		public function PresenceValidator(options:Object)
		{
			if (!options.hasOwnProperty("message")) {
				options.message = "can't be empty";
			}
			
			super(options);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):void
		{
			if (isEmpty(value)) {
				obj.errors.add(property, options.message);
			}
		}
	}
}