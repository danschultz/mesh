package mesh.model.source
{
	import mesh.model.Record;

	/**
	 * The <code>IPersistenceResponder</code> interface is an interface that classes can 
	 * implement to handle persistence callbacks from a data source.
	 * 
	 * @author Dan Schultz
	 */
	public interface IPersistenceResponder
	{
		/**
		 * The data source calls this method when it has successfully persisted a record.
		 * 
		 * @param record The record that was persisted.
		 * @param id An ID to set on the record.
		 */
		function saved(record:Record, id:Object = null):void;
		
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