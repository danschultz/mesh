package mesh
{
	import operations.Operation;

	public interface IPersistable
	{
		function batch(batch:SaveBatch):void;
		
		function createSave():Operation;
		
		function save():Operation;
	}
}