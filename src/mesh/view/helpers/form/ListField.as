package mesh.view.helpers.form
{
	import spark.components.List;

	public class ListField extends FormField
	{
		public function ListField()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			addElement(createList());
		}
		
		/**
		 * Creates a list that is configured for this form field.
		 * 
		 * @return A new lsit.
		 */
		protected function createList():List
		{
			return new List();
		}
	}
}