package validations
{
	/**
	 * Validates the bounds of a numeric value. One of the following options must be defined
	 * for this validation:
	 * 
	 * <ul>
	 * <li><code>equalTo</code></li>
	 * <li><code>greaterThan</code></li>
	 * <li><code>greaterThanOrEqualTo</code></li>
	 * <li><code>lessThan</code></li>
	 * <li><code>lessThanOrEqualTo</code></li>
	 * <li><code>between:i..k</code></li>
	 * </ul>
	 * 
	 * @author Dan Schultz
	 */
	public class NumericValidator extends EachValidator
	{
		private static const CHECKS:Object = 
		{
			equalTo:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue == validationValue;
			},
			greaterThan:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue > validationValue;
			},
			greaterThanOrEqualTo:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue >= validationValue;
			},
			lessThan:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue < validationValue;
			},
			lessThanOrEqualTo:function(propertyValue:Number, validationValue:Number):Boolean
			{
				return propertyValue <= validationValue;
			}
		};
		
		/**
		 * @copy Validator#Validator()
		 */
		public function NumericValidator(options:Object)
		{
			super(options);
			populateRangeInOptions("between", "greaterThanOrEqualTo", "lessThanOrEqualTo");
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):Object
		{
			for (var check:String in CHECKS) {
				if (options.hasOwnProperty(check)) {
					if (!CHECKS[check](value, options[check])) {
						return failWithMessage("{0} must be {1} {2}", property, check, options[check]);
					}
				}
			}
			return passed();
		}
	}
}