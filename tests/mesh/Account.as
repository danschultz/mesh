package mesh
{
	import mesh.core.object.copy;
	
	public class Account extends TestEntity
	{
		[Bindable] public var customer:Customer;
		[Bindable] public var number:String;
		
		public function Account()
		{
			super();
		}
		
		override public function toObject():Object
		{
			var object:Object = super.toObject();
			copy(this, object, {includes:["number"]});
			return object;
		}
	}
}