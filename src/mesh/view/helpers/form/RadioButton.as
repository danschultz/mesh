package mesh.view.helpers.form
{
	import spark.components.RadioButton;

	public class RadioButton extends FormField
	{
		private var _radioButton:spark.components.RadioButton;
		
		public function RadioButton()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override protected function childrenCreated():void
		{
			super.createChildren();
			
			_radioButton = new spark.components.RadioButton();
			_radioButton.groupName = property;
			_radioButton.label = value.toString();
			addElement(_radioButton);
		}
	}
}