package mesh.validators
{
	import collections.HashSet;

	/**
	 * A helper that validates that a property's value belongs to a given set of values. This
	 * set can be an array or any enumerable object.
	 * 
	 * @author Dan Schultz
	 */
	public class InclusionValidator extends EachValidator
	{
		/**
		 * @copy Validator#Validator()
		 */
		public function InclusionValidator(options:Object)
		{
			if (!options.hasOwnProperty("message")) {
				options.message = "is not included in the list";
			}
			
			super(options);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function validateProperty(obj:Object, property:String, value:Object):void
		{
			if (!new HashSet(options.within).contains(value)) {
				obj.errors.add(property, options.message);
			}
		}
	}
}