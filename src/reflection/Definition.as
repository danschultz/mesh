package reflection
{
	import flash.errors.IllegalOperationError;

	/**
	 * A definition is a base class for any property, variable, constant, metadata, or 
	 * method that is specified on a class.
	 * 
	 * @author Dan Schultz
	 */
	public class Definition
	{
		/**
		 * Constructor.
		 * 
		 * @param name The name of the definition.
		 * @param belongsTo The definition that this belongs to.
		 * @param description The XML that describes this definition.
		 */
		public function Definition(name:String, belongsTo:Definition, description:XML)
		{
			_belongsTo = belongsTo;
			_name = name;
			_description = description;
		}
		
		/**
		 * Returns the name of the definition.
		 * 
		 * @return The definition's name.
		 */
		public function toString():String
		{
			return name;
		}
		
		private var _belongsTo:Definition;
		/**
		 * The definition that this definition belongs to.
		 */
		protected function get belongsTo():Definition
		{
			return _belongsTo;
		}
		
		private var _description:XML;
		/**
		 * The raw XML description for this definition.
		 */
		public function get description():XML
		{
			return _description;
		}
		
		private var _metadata:Array;
		/**
		 * A list of <code>Metadata</code> definitions that are specified on this definition.
		 */
		public function get metadata():Array
		{
			if (_metadata == null) {
				_metadata = [];
				
				for each (var metadataXML:XML in description..metadata.(@name != "__go_to_definition_help")) {
					_metadata.push(new Metadata(metadataXML.@name.toString(), this));
				}
			}
			return _metadata.concat();
		}
		
		private var _name:String;
		/**
		 * The name of the definition, such as the property's or method's name.
		 */
		public function get name():String
		{
			return _name;
		}
	}
}