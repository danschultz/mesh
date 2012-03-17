package mesh.model.store
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mesh.core.object.merge;
	import mesh.model.Record;
	
	import mx.utils.UIDUtil;
	
	/**
	 * The <code>ExternalData</code> class wraps data that is retrieved from a data source and is
	 * inserted into the store.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Data extends Proxy
	{
		private var _data:Object;
		private var _options:Object;
		
		/**
		 * Constructor. When instantiating a new data object, you can pass an options hash with the
		 * following options:
		 * 
		 * <ul>
		 * <li><code>idField:String</code> - (default="<code>id</code>") The name of the ID field on
		 * 	the data object.</li>
		 * <li><code>parser:Function</code> - A function that's called when transfering the values
		 * 	from the data to a record.
		 * </ul>
		 * 
		 * @param type The record type that maps to this data.
		 * @param data The data from the data source.
		 * @param options A set of options to configure this data object.
		 */
		public function Data(type:Class, data:Object, options:Object = null)
		{
			super();
			_data = data;
			_type = type;
			_options = merge({idField:"id", deserializer:transfer}, options);
		}
		
		/**
		 * Checks if two data objects are equal. Data objects are equal if they're keys are the same,
		 * or if the record types are the same and the objects have the same ID.
		 * 
		 * @param obj The object to check.
		 * @return <code>true</code> if the data is equal.
		 */
		public function equals(obj:Object):Boolean
		{
			if (obj is Data) {
				return (key == (obj as Data).key) || (type == (obj as Data).type && id == (obj as Data).id);
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return _data[name];
		}
		
		/**
		 * Returns the key that has been given to this data; 
		 * 
		 * @return The data's key.
		 */
		public function hashCode():Object
		{
			return key;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			_data[name] = value;
		}
		
		private function transfer(record:Record, data:Object):void
		{
			for (var key:String in data) {
				if (record.hasOwnProperty(key)) {
					try {
						record[key] = data[key];
					} catch (e:Error) {
						
					}
				}
			}
		}
		
		/**
		 * Transfers the values on this data to the given object.
		 * 
		 * @param to The object to set the values on.
		 */
		public function transferValues(to:Object):void
		{
			_options.deserializer(to, _data);
			to.id = id;
		}
		
		/**
		 * The ID that was assigned to this data by the data source.
		 */
		public function get id():Object
		{
			return _data[_options.idField];
		}
		
		private var _key:Object;
		/**
		 * A global unique key given to this data by the store.
		 */
		public function get key():Object
		{
			if (_key == null) {
				_key = UIDUtil.createUID();
			}
			return _key;
		}
		
		private var _type:Class;
		/**
		 * The record type that maps to this data.
		 */
		public function get type():Class
		{
			return _type;
		}
	}
}