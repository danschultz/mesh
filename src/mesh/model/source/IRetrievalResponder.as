package mesh.model.source
{
	/**
	 * The <code>IRetrievalResponder</code> interface is an interface that classes can 
	 * implement to handle retrieval callbacks from a data source.
	 * 
	 * @author Dan Schultz
	 */
	public interface IRetrievalResponder
	{
		/**
		 * The data source calls this method when a record's data has been loaded. You
		 * can optionally specify the ID for the data.
		 * 
		 * @param type The record type that was loaded.
		 * @param data The data for the record.
		 * @param id An optional ID.
		 */
		function loaded(type:Class, data:Object, id:Object = null):void;
		
		/**
		 * The data source calls this method when it has finished retrieving the data for
		 * the request.
		 */
		function finished():void;
		
		/**
		 * The data source calls this method when data retrieval has failed.
		 * 
		 * @param summary The summary of the error.
		 * @param detail A detailed message of the error.
		 * @param code An error code.
		 */
		function failed(summary:String, detail:String = "", code:String = ""):void;
	}
}