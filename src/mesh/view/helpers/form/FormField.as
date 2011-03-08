package mesh.view.helpers.form
{
	import mesh.core.inflection.humanize;
	import mesh.core.string.capitalize;
	
	import spark.components.FormItem;
	
	public class FormField extends FormItem
	{
		public function FormField()
		{
			super();
		}
		
		private var _property:String;
		/**
		 * The property name on the entity to use.
		 */
		public function get property():String
		{
			return _property;
		}
		public function set property(value:String):void
		{
			_property = value;
			
			if (label == null || label.length == 0) {
				label = capitalize(humanize(value));
			}
		}
		
		private var _value:Object;
		/**
		 * The value for the control of this field.
		 */
		public function get value():Object
		{
			return _value;
		}
		public function set value(value:Object):void
		{
			_value = value;
		}
	}
}