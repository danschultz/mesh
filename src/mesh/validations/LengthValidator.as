package mesh.validations
{
	/**
	 * Validates the length of an object, such as the length of string or number of
	 * elements in an array.
	 * 
	 * @author Dan Schultz
	 */
	public class LengthValidator extends Validator
	{
		/**
		 * The minimum length that the object must meet to pass.
		 */
		public var minimum:Number;
		
		/**
		 * The maximum length that the object must meet to pass.
		 */
		public var maximum:Number;
		
		/**
		 * The exact length that the object must be to validate.
		 */
		public var length:Number;
		
		/**
		 * The length property on the object.
		 */
		public var lengthProperty:String = "length";
		
		/**
		 * Constructor.
		 */
		public function LengthValidator()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function validate(obj:Object):Object
		{
			var value:int = obj[lengthProperty];
			
			if (!isNaN(length) && value != length) {
				// return error.
			}
			
			if (!isNaN(minimum) && value < minimum) {
				// return error.
			}
			
			if (!isNaN(maximum) && value > maximum) {
				// return error.
			}
			
			return null;
		}
	}
}