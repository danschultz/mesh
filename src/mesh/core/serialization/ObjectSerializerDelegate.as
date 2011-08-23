package mesh.core.serialization
{
	/**
	 * A serialization delegate that serializes the properties of an object into a simple
	 * Flash <code>Object</code>.
	 * 
	 * @author Dan Schultz
	 */
	public class ObjectSerializerDelegate implements ISerializerDelegate
	{
		/**
		 * Constructor.
		 */
		public function ObjectSerializerDelegate()
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function node():ISerializerDelegate
		{
			return new ObjectSerializerDelegate();
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeProperty(name:String, value:Object):void
		{
			if (value != null && value.hasOwnProperty("toArray")) {
				value = value.toArray();
			}
			
			if (value is Array) {
				value = value.concat();
			}
			
			if (value is Date) {
				value = new Date(value.valueOf());
			}
			
			_serialized[name] = value;
		}
		
		private var _serialized:Object = {};
		/**
		 * @inheritDoc
		 */
		public function get serialized():*
		{
			return _serialized;
		}
	}
}