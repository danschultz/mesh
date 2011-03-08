package mesh.view.helpers.form
{
	import spark.components.CheckBox;

	public class CheckBoxField extends FormField
	{
		private var _checkBox:spark.components.CheckBox;
		
		/**
		 * Constructor.
		 */
		public function CheckBoxField()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			_checkBox = new spark.components.CheckBox();
			addElement(_checkBox);
		}
	}
}