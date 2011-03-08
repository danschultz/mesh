package mesh.view.helpers.form
{
	import mesh.Entity;
	
	import spark.components.Form;

	public class Form extends spark.components.Form
	{
		/**
		 * Constructor.
		 */
		public function Form()
		{
			super();
		}
		
		private var _entity:Entity;
		/**
		 * 
		 */
		public function get entity():Entity
		{
			return _entity;
		}
		public function set entity(value:Entity):void
		{
			_entity = value;
		}
	}
}