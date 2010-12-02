package mesh
{
	import operations.EmptyOperation;
	import operations.Operation;

	/**
	 * An association proxy is a class that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the 
	 * association, and the <em>target</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public class AssociationProxy
	{
		public function AssociationProxy(owner:Entity, relationship:Relationship)
		{
			_owner = owner;
			_relationship = relationship;
		}
		
		public function load():Operation
		{
			return new EmptyOperation();
		}
		
		private var _isLoaded:Boolean;
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		private var _relationship:Relationship;
		protected function get relationship():Relationship
		{
			return _relationship;
		}
		
		private var _owner:Entity;
		protected function get owner():Entity
		{
			return _owner;
		}
		
		private var _target:Object;
		protected function get target():Object
		{
			return _target;
		}
		protected function set target(value:Object):void
		{
			_target = value;
		}
	}
}