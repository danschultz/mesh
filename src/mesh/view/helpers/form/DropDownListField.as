package mesh.view.helpers.form
{
	import spark.components.DropDownList;
	import spark.components.List;

	public class DropDownListField extends ListField
	{
		public function DropDownListField()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createList():List
		{
			return new DropDownList();
		}
	}
}