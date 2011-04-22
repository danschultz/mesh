package mesh.model.validators
{
	/**
	 * A validator that tests a value against a regular expression.
	 * 
	 * @author Dan Schultz
	 */
	public class FormatValidator extends EachValidator
	{
		/**
		 * @copy Validator#Validator()
		 */
		public function FormatValidator(options:Object)
		{
			super(options);
			
			if (!options.hasOwnProperty("message")) {
				options.message = "is invalid";
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):void
		{
			if (!options.format.test(value.toString())) {
				obj.errors.add(property, options.message);
			}
		}
	}
}