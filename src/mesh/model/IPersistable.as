package mesh.model
{
	import mesh.model.store.ICommitResponder;

	/**
	 * The <code>IPersistable</code> interface defines an interface for objects that
	 * can be persisted.
	 * 
	 * @author Dan Schultz
	 */
	public interface IPersistable
	{
		function save(responder:ICommitResponder = null):*;
	}
}