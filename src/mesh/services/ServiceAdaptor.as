package mesh.services
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.Type;
	import mesh.model.Entity;
	import mesh.operations.Operation;
	
	/**
	 * A service adaptor represents the required strategy for an entity to be persisted and
	 * retrieved from some backend service.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class ServiceAdaptor
	{
		private var _factory:Function;
		
		/**
		 * Constructor.
		 */
		public function ServiceAdaptor(factory:Function, options:Object = null)
		{
			_options = options == null ? {} : options;
			_factory = factory;
		}
		
		/**
		 * Generates an operation that is specific for this service adaptor.
		 * 
		 * @param args The args to pass to the constructor of the operation.
		 * @return A new unexecuted operation.
		 */
		protected function createOperation(...args):Operation
		{
			throw new IllegalOperationError(reflect.name + ".createOperation() is not implemented.");
		}
		
		protected function deserialize(objects:Array):Array
		{
			return objects.map(function(object:Object, ...args):Entity
			{
				var entity:Entity = _factory(object);
				entity.translateFrom(object);
				return entity;
			});
		}
		
		protected function serialize(entities:Array):Array
		{
			return entities.map(function(entity:Entity, ...args):Object
			{
				return entity.translateTo();
			});
		}
		
		private var _options:Object;
		/**
		 * A set of options to configure this service adaptor.
		 */
		protected function get options():Object
		{
			return _options;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection on this object.
		 */
		protected function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
	}
}