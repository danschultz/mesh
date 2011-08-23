package mesh.core.serialization
{
	/**
	 * The delegate that is passed to an <code>ISerializer</code> for writing the serialized data.
	 * Delegates can be created for serializing objects into different formats. For instance, you
	 * can create a JSON or XML delegate for serializing data into those formats.
	 * 
	 * @author Dan Schultz
	 */
	public interface ISerializerDelegate
	{
		/**
		 * Called by the serializer when a new node needs to be created.
		 * 
		 * @return A new delegate.
		 */
		function node():ISerializerDelegate;
		
		/**
		 * Writes the property to the current node.
		 * 
		 * @param name The property's name.
		 * @param value The property's value.
		 */
		function writeProperty(name:String, value:Object):void;
		
		/**
		 * The serialized node.
		 */
		function get serialized():*
	}
}