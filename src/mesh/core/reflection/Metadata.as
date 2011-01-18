package mesh.core.reflection
{
	/**
	 * A class that represents the metadata that has been defined on a class, variable, or
	 * method.
	 * 
	 * @author Dan Schultz
	 */
	public class Metadata extends Definition
	{
		/**
		 * @copy Definition#Definition()
		 */
		public function Metadata(description:XML, belongsTo:Definition)
		{
			super(description, belongsTo);
		}
		
		private var _arguments:Object;
		/**
		 * Returns an arguments hash that represents the key-value pairs that are
		 * defined for this metadata.
		 */
		public function get arguments():Object
		{
			if (_arguments == null) {
				_arguments = {};
				
				for each (var argXML:XML in description..arg) {
					_arguments[argXML.@key.toString()] = argXML.@value.toString();
				}
			}
			return _arguments;
		}
	}
}