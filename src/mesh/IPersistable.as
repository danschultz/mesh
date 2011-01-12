package mesh
{
	import operations.Operation;

	public interface IPersistable
	{
		function batch(batch:Batch):void;
		
		function save():Operation;
	}
}