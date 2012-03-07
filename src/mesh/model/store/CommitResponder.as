package mesh.model.store
{
	/**
	 * A responder that contains callbacks for failed and successful persistence events.
	 * 
	 * @author Dan Schultz
	 */
	public class CommitResponder implements ICommitResponder
	{
		/**
		 * Constructor.
		 * 
		 * @param success The success callback function.
		 * @param failed The failed callback function.
		 */
		public function CommitResponder(success:Function = null, failed:Function = null)
		{
			successHandler = success;
			failedHandler = failed;
		}
		
		/**
		 * @inheritDoc
		 */
		public function failed(summary:String, detail:String = "", code:String = ""):void
		{
			if (failedHandler != null) {
				failedHandler(summary, detail, code);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function success():void
		{
			if (successHandler != null) {
				successHandler();
			}
		}
		
		/**
		 * The function that is executed when a commit has failed. This method expects the following 
		 * method signature: <code>function(summary:String, detail:String = "", code:String = ""):void</code>.
		 */
		public var failedHandler:Function;
		
		/**
		 * The function that is executed when a commit has finished successfully. This method expects
		 * the following method signature: <code>function():void</code>.
		 */
		public var successHandler:Function;
	}
}