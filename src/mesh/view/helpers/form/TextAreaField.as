package mesh.view.helpers.form
{
	import spark.components.TextArea;

	public class TextAreaField extends FormField
	{
		private var _textArea:spark.components.TextArea
		
		public function TextAreaField()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			_textArea = new spark.components.TextArea();
			addElement(_textArea);
		}
	}
}