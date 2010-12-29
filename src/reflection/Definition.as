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
		public function Definition(description:XML, belongsTo:Definition)
		{
			_belongsTo = belongsTo;
			_description = description;
		}
		
		/**
		 * Checks that two definitions are equal. Two definitions are equal when they belong
		 * to the same definition, and their names are equal.
		 * 
		 * @param definition The definition to check.
		 * @return <code>true</code> if the definitions are equal.
		 */
		public function equals(definition:Definition):Boolean
		{
			return this == definition || (definition != null && name == definition.name && belongsTo.equals(definition.belongsTo));
		}
		
		/**
		 * Returns the name for this definition.
		 * 
		 * @return The name.
		 */
		public function hashCode():Object
		{
			return name;
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
				
				for each (var metadataXML:XML in description..metadata) {
					if (metadataXML.@name.toString() != "__go_to_definition_help") {
						_metadata.push(new Metadata(metadataXML, this));
					}
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
			if (_name == null) {
				_name = description.@name.toString()
			}
			return _name;
		}
	}
}