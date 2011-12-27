package mesh.store
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mesh.core.object.merge;
	import mesh.mesh_internal;
	
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
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return _data[name];
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