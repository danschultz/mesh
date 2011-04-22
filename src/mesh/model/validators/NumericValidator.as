package mesh.model.validators
{
	import mesh.core.inflection.humanize;

	/**
	 * Validates if a property's value is a number and also the bounds of that value. This validator has
	 * the following options:
	 * 
	 * <ul>
	 * <li><code>integer</code></li>
	 * <li><code>odd</code></li>
	 * <li><code>even</code></li>
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
			number:function(propertyValue:Number, ...args):Boolean
			{
				return !isNaN(propertyValue);
			},
			integer:function(propertyValue:Number, ...args):Boolean
			{
				return propertyValue.toString().search(/\A[+-]?\d+\Z/) == 0;
			},
			even:function(propertyValue:Number, ...args):Boolean
			{
				return (propertyValue % 2) == 0;
			},
			odd:function(propertyValue:Number, ...args):Boolean
			{
				return (propertyValue % 2) != 0;
			},
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
		
		private static const MESSAGES:Object = 
		{
			number:"is not a {check}",
			integer:"is not an {check}",
			even:"must be {check}",
			odd:"must be {check}",
			greaterThan:"must be {check} {count}",
			greaterThanOrEqualTo:"must be {check} {count}",
			equalTo:"must be {check} {count}",
			lessThan:"must be {check} {count}",
			lessThanOrEqualTo:"must be {check} {count}"
		};
		
		/**
		 * @copy Validator#Validator()
		 */
		public function NumericValidator(options:Object)
		{
			super(options);
			options.number = true;
			populateRangeInOptions("between", "greaterThanOrEqualTo", "lessThanOrEqualTo");
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):void
		{
			for (var check:String in CHECKS) {
				if (options.hasOwnProperty(check)) {
					if (!CHECKS[check](value, options[check])) {
						obj.errors.add(property, MESSAGES[check], {check:humanize(check).toLowerCase(), count:options[check]});
					}
				}
			}
		}
	}
}