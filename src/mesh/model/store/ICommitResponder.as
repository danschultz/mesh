package mesh.model.store
{
	/**
	 * The <code>ICommitResponder</code> interface is an interface that classes can implement to 
	 * handle callbacks from a commit.
	 * 
	 * @author Dan Schultz
	 */
	public interface ICommitResponder
	{
		/**
		 * The commit calls this method when it has failed to persist its records.
		 * 
		 * @param summary The summary of the error.
		 * @param detail A detailed message of the error.
		 * @param code An error code.
		 */
		function failed(summary:String, detail:String = "", code:String = ""):void;
		
		/**
		 * The commit call this method when persistence of all its records are successful.
		 */
		function success():void;
	}
}