package mesh
{
	import mesh.core.object.copy;
	import mesh.model.Entity;
	
	public class TestEntity extends Entity
	{
		public function TestEntity(values:Object=null)
		{
			super(values);
		}
		
		public function fromObject(object:Object):void
		{
			copy(object, this);
		}
		
		public function toObject():Object
		{
			var obj:Object = {};
			copy(this, obj, {includes:["id"]});
			return obj;
		}
	}
}