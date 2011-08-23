package mesh
{
	import mesh.core.object.copy;
	
	[RemoteClass(alias="mesh.Account")]
	
	public class Account extends TestEntity
	{
		[Bindable] public var customer:Customer;
		[Bindable] public var number:String;
		
		public function Account(properties:Object = null)
		{
			super(properties);
			hasOne("customer");
		}
		
		override public function toObject():Object
		{
			var object:Object = super.toObject();
			copy(this, object, {includes:["number"]});
			return object;
		}
	}
}