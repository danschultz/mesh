package mesh.view.helpers.form
{
	import spark.components.TextInput;

	public class NumberField extends TextField
	{
		public function NumberField()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createTextField():TextInput
		{
			var textField:TextInput = super.createTextField();
			textField.restrict = "0-9.,";
			return textField;
		}
	}
}