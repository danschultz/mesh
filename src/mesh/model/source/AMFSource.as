package mesh.model.source
{
	import mx.rpc.remoting.RemoteObject;
	
	/**
	 * The <code>AMFSource</code> class is used by sources that need to communicate with an AMF
	 * destination.
	 * 
	 * @author Dan Schultz
	 */
	public class AMFSource extends RPCSource
	{
		/**
		 * Constructor.
		 */
		public function AMFSource()
		{
			var service:RemoteObject = new RemoteObject();
			super(service);
			configure(service);
		}
		
		/**
		 * Called during creation to allow sub-classes to configure the service.
		 * 
		 * @param service The source's service.
		 */
		protected function configure(service:RemoteObject):void
		{
			
		}
	}
}