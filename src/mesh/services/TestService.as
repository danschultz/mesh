package mesh.services
{
	import mesh.Entity;
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
		
		override public function findOne(id:*):QueryRequest
		{
			return new QueryRequest(this, function():Operation
			{
				return adaptor.createOperation("findOne", id);
			});
		}
		
		override public function findMany(...ids):QueryRequest
		{
			return new ListQueryRequest(this, function():Operation
			{
				return adaptor.createOperation("findMany", ids);
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
			return newInstance(clazz, entities, function():Operation
			{
				return adaptor.createOperation(type, entities);
			});
		}
		
		override public function get adaptor():ServiceAdaptor
		{
			return new TestServiceAdaptor(function(object:Object):Entity
			{
				return new _entity();
			});
		}
	}
}