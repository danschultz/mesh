package mesh.model.store
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mesh.core.object.merge;
	import mesh.mesh_internal;
	
	import mx.utils.UIDUtil;
	
	use namespace mesh_internal;
	
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
		 * </ul>
		 * 
		 * @param data The data from the data source.
		 * @param type The record type that maps to this data.
		 * @param options A set of options to configure this data object.
		 */
		public function Data(data:Object, type:Class, options:Object = null)
		{
			super();
			_data = data;
			_type = type;
			_options = merge({idField:"id"}, options);
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
		
		/**
		 * The ID that was assigned to this data by the data source.
		 */
		public function get id():Object
		{
			return this[_options.idField];
		}
		
		private var _key:Object;
		/**
		 * A global unique key given to this data by the store.
		 */
		mesh_internal function get key():Object
		{
			if (_key == null) {
				_key = UIDUtil.createUID();
			}
			return _key;
		}
		
		private var _state:LifeCycleState = LifeCycleState.CREATED;
		/**
		 * The state of the data, i.e. new, persisted or destroyed.
		 */
		mesh_internal function get state():LifeCycleState
		{
			return _state;
		}
		
		private var _status:SyncState = SyncState.SYNCED;
		/**
		 * The status of the data in relation to the data's source.
		 */
		mesh_internal function get status():SyncState
		{
			return _status;
		}
		
		private var _type:Class;
		/**
		 * The record type that maps to this data.
		 */
		mesh_internal function get type():Class
		{
			return _type;
		}
	}
}