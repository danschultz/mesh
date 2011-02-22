package mesh.adaptors
{
	import mx.rpc.remoting.RemoteObject;
	
	/**
	 * A service adaptor that uses a <code>RemoteObject</code> to perform persistence with a backend.
	 * 
	 * <p>
	 * Any options that are defined on the <code>[ServiceAdaptor]</code> metadata or passed to 
	 * the constructor, will tried to be set on the adaptor's service.
	 * 
	 * <p>
	 * <strong>Example:</strong> Setting the busy cursor for the service.
	 * <pre listing="3.0">
	 * [ServiceAdaptor(showBusyCursor="true")]
	 * </pre>
	 * </p>
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class AMFServiceAdaptor extends RPCServiceAdaptor
	{
		/**
		 * Constructor.
		 * 
		 * @param entity The entity who owns this service adaptor.
		 * @param options An options hash to configure the adaptor.
		 */
		public function AMFServiceAdaptor(entity:Class, options:Object)
		{
			super(new RemoteObject(), entity, options);
		}
	}
}