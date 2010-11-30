package validations
{
	/**
	 * Validates the length of an object, such as the length of string or number of
	 * elements in an array.
	 * 
	 * @author Dan Schultz
	 */
	public class LengthValidator extends EachValidator
	{
		private static const CHECKS:Object =
		{
			length:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue == validationValue;
			},
			minimum:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue >= validationValue;
			},
			maximum:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue <= validationValue;
			}
		};
		
		private static const MESSAGES:Object = 
		{
			length:"{0} must be a length of {1}",
			minimum:"{0} is too short (minimum is {1})",
			maximum:"{0} is too long (maximum is {1})"
		}
		
		/**
		 * @copy Validator#Validator()
		 */
		public function LengthValidator(options:Object)
		{
			if (!options.hasOwnProperty("lengthProperty")) {
				options.lengthProperty = "length";
			}
			
			super(options);
			populateRangeInOptions("between", "minimum", "maximum");
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):Object
		{
			value = value[options.lengthProperty];
			
			for (var check:String in CHECKS) {
				if (options.hasOwnProperty(check)) {
					if (!CHECKS[check](value, options[check])) {
						return failWithMessage(MESSAGES[check], property, options[check]);
					}
				}
			}
			
			return passed();
		}
	}
}