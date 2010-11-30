package validations
{
	/**
	 * A class that represents a test to run on an object to ensure a correct state.
	 * 
	 * @author Dan Schultz
	 */
	public class Validator
	{
		/**
		 * Constructor.
		 * 
		 * @param options A set of options for this validator, as key-value pairs.
		 */
		public function Validator(options:Object)
		{
			_options = options;
		}
		
		/**
		 * A utility method for sub-classes to parse and populate the fields for a numeric range.
		 * This method will take a string defined on <code>options[rangeField]</code> in the format
		 * <code>i..k</code>, and set <code>options[lowerField] = i</code> and <code>options[upperField] = k</code>.
		 * 
		 * @param rangeField The field defining a range.
		 * @param lowerField The field defining the lower bounds of the range.
		 * @param upperField The field defining the upper bounds of the range.
		 */
		protected function populateRangeInOptions(rangeField:String, lowerField:String, upperField:String):void
		{
			if (options.hasOwnProperty(rangeField)) {
				var parsedRange:Array = options[rangeField].split("..");
				options[lowerField] = parsedRange[0];
				options[upperField] = parsedRange[1];
			}
		}
		
		/**
		 * Called by sub-classes to indicate that the validator failed. This method will
		 * return a validation error that contains the given message. This method has an
		 * option of replacing instances of <code>{n}</code> with values that you pass in
		 * the <code>replacements</code> rest parameter.
		 * 
		 * <listing version="3.0">
		 * trace(failWithMessage("replacement 1: {0}, replacement 2: {1}", "a", "b")); // message is: "replacement 1: a, replacement 2: b"
		 * </listing>
		 * 
		 * @param message The message of the error.
		 * @param replacements The sequence of replacements
		 * @return An error.
		 */
		protected function failWithMessage(message:String, ...replacements):ValidationError
		{
			if (!options.hasOwnProperty("message")) {
				for (var i:int = 0; i < replacements.length; i++) {
					message = message.replace(new RegExp("\{" + i.toString() + "\}"), replacements[i]);
				}
				return new ValidationError(message);
			}
			return new ValidationError(message);
		}
		
		/**
		 * Called by sub-classes to indicate that the validator was successful.
		 * 
		 * @return An empty array.
		 */
		protected function passed():Array
		{
			return [];
		}
		
		/**
		 * Executes the validation on the given object, and returns a list of validation errors
		 * for validations that have failed. If all validations pass, this method returns an 
		 * empty array.
		 * 
		 * @param obj The object to validate.
		 * @return A list of <code>ValidationError</code>s.
		 */
		public function validate(obj:Object):Array
		{
			return passed();
		}
		
		private var _options:Object;
		/**
		 * The options that were defined for this validator as key-value pairs.
		 */
		public function get options():Object
		{
			return _options;
		}
	}
}