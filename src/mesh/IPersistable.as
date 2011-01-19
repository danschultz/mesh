package mesh
{
	import operations.Operation;

	public interface IPersistable
	{
		function batch(batch:SaveBatch):void;
		
		function save(validate:Boolean = true):Operation;
	}
}