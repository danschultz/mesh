package mesh.view.helpers.form
{
	import spark.components.TextInput;

	public class PasswordField extends TextField
	{
		public function PasswordField()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createTextField():TextInput
		{
			var textField:TextInput = super.createTextField();
			textField.displayAsPassword = true;
			return textField;
		}
	}
}