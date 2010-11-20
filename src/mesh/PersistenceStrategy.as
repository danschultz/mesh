package mesh
{
	import collections.HashSet;
	
	import operations.Operation;

	public class PersistenceStrategy
	{
		public function PersistenceStrategy()
		{
			
		}
		
		public function insert(entities:HashSet):Operation
		{
			return new Operation();
		}
		
		public function remove(entities:HashSet):Operation
		{
			return new Operation();
		}
		
		public function update(entities:HashSet):Operation
		{
			return new Operation();
		}
	}
}