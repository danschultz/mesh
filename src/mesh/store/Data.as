package mesh.store
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	/**
	 * The <code>Data</code> class wraps data that is retrieved from a data source and is
	 * inserted into the store.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Data extends Proxy
	{
		private var _data:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param data The data from the data source.
		 * @param id The ID that has been given to the data from the data source.
		 */
		public function Data(data:Object, id:Object = null)
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
	}
}