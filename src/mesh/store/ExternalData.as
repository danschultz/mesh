package mesh.store
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mesh.mesh_internal;
	
	/**
	 * The <code>ExternalData</code> class wraps data that is retrieved from a data source and is
	 * inserted into the store.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class ExternalData extends Proxy
	{
		private var _data:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param data The data from the data source.
		 * @param id The ID that has been given to the data from the data source.
		 */
		public function ExternalData(data:Object, id:Object = null)
		{
			super();
			_data = data;
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
	}
}