package mesh.view.helpers.form
{
	import spark.components.TextInput;

	public class TextField extends FormField
	{
		/**
		 * Constructor.
		 */
		public function TextField()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			addElement(createTextField());
		}
		
		/**
		 * Creates a text input field that is configured for this form field.
		 * 
		 * @return A new text input.
		 */
		protected function createTextField():TextInput
		{
			return new TextInput();
		}
	}
}