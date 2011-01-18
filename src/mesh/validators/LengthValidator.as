package mesh.validators
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
			length:"wrongLength",
			minimum:"tooShort",
			maximum:"tooLong"
		};
		
		/**
		 * @copy Validator#Validator()
		 */
		public function LengthValidator(options:Object)
		{
			if (!options.hasOwnProperty("lengthProperty")) {
				options.lengthProperty = "length";
			}
			
			if (!options.hasOwnProperty("wrongLength")) {
				options.wrongLength = "must be a length of {count}";
			}
			
			if (!options.hasOwnProperty("tooShort")) {
				options.tooShort = "is too short (minimum is {count})";
			}
			
			if (!options.hasOwnProperty("tooLong")) {
				options.tooLong = "is too long (maximum is {count})";
			}
			
			super(options);
			populateRangeInOptions("between", "minimum", "maximum");
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):void
		{
			for (var check:String in CHECKS) {
				if (options.hasOwnProperty(check)) {
					if (!CHECKS[check](value[options.lengthProperty], options[check])) {
						obj.errors.add(property, options[MESSAGES[check]], {count: options[check]});
					}
				}
			}
		}
	}
}