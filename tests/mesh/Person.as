package mesh
{
	import mesh.core.object.copy;
	import mesh.model.validators.NumericValidator;
	import mesh.model.validators.PresenceValidator;
	
	[RemoteClass(alias="mesh.Person")]
	
	public class Person extends TestEntity
	{
		public static var validate:Object = 
		{
			name: [{validator:PresenceValidator}],
			age: [{validator:NumericValidator, greaterThan:0, integer:true}]
		};
		
		[Bindable] public var age:Number;
		[Bindable] public var name:Name;
		
		public function Person(properties:Object = null)
		{
			super(properties);
		}
		
		override public function toObject():Object
		{
			var obj:Object = super.toObject();
			copy(this, obj, {includes:["age", "name"]});
			return obj;
		}
	}
}