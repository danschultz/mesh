package mesh.services
{
	import mx.rpc.remoting.RemoteObject;
	
	public class AMFService extends RPCService
	{
		public function AMFService(factory:Function)
		{
			super(new RemoteObject(), factory);
		}
	}
}