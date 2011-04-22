package mesh.services
{
	import mx.rpc.remoting.RemoteObject;
	
	public class AMFService extends RPCService
	{
		public function AMFService(entity:Class, options:Object = null)
		{
			super(new RemoteObject(), entity, options);
		}
	}
}