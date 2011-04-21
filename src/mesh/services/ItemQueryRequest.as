package mesh.services
{
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public dynamic class ItemQueryRequest extends QueryRequest
	{
		public function ItemQueryRequest(service:Service, deserializer:Function, block:Function)
		{
			super(service, deserializer, block);
		}
		
		override flash_proxy function set object(value:*):void
		{
			if (value is Array) {
				value = value[0];
			}
			super.object = value; 
		}
	}
}