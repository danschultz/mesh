package mesh
{
	import mesh.model.Entity;
	import mesh.model.validators.NumericValidator;
	import mesh.model.validators.PresenceValidator;
	
	[RemoteClass(alias="mesh.Person")]
	
	public class Person extends Entity
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
		
		override public function fromObject(object:Object):void
		{
			super.fromObject(object);
			name = object.name != null ? new Name(object.name.first, object.name.last) : null;
		}
		
		override protected function get serializableOptions():Object
		{
			return {
				exclude:["state", "storeKey"],
				includes:{
					name:true
				}
			};
		}
	}
}