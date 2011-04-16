package mesh.services
{
	import mesh.model.Entity;
	import mesh.core.reflection.newInstance;
	import mesh.operations.Operation;
	
	public class TestService extends Service
	{
		private var _entity:Class;
		
		public function TestService(entity:Class)
		{
			super();
			_entity = entity;
		}
		
		override public function belongingTo(entity:Entity):QueryRequest
		{
			return new QueryRequest(this, function():Operation
			{
				return adaptor.belongingTo(this);
			});
		}
		
		override public function findOne(id:*):QueryRequest
		{
			return new QueryRequest(this, function():Operation
			{
				return adaptor.findOne(id);
			});
		}
		
		override public function findMany(...ids):ListQueryRequest
		{
			return new ListQueryRequest(this, function():Operation
			{
				return adaptor.findMany(ids);
			});
		}
		
		override protected function createInsert(entities:Array):InsertRequest
		{
			return createPesistRequest(InsertRequest, "insert", entities);
		}
		
		override protected function createDestroy(entities:Array):DestroyRequest
		{
			return createPesistRequest(DestroyRequest, "destroy", entities);
		}
		
		override protected function createUpdate(entities:Array):UpdateRequest
		{
			return createPesistRequest(UpdateRequest, "update", entities);
		}
		
		private function createPesistRequest(clazz:Class, type:String, entities:Array):*
		{
			return newInstance(clazz, this, entities, function():Operation
			{
				return adaptor[type](entities);
			});
		}
		
		private var _adaptor:ServiceAdaptor;
		override public function get adaptor():ServiceAdaptor
		{
			if (_adaptor == null) {
				_adaptor = new TestServiceAdaptor(function(object:Object):Entity
				{
					return new _entity();
				});
			}
			return _adaptor;
		}
	}
}