package mesh.view.helpers.form
{
	import spark.components.ComboBox;
	import spark.components.List;

	public class ComboBoxField extends ListField
	{
		public function ComboBoxField()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createList():List
		{
			return new ComboBox();
		}
	}
}