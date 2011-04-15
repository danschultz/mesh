package mesh
{
	import mesh.model.Entity;
	import mesh.core.object.copy;
	import mesh.model.validators.LengthValidator;
	import mesh.model.validators.NumericValidator;
	import mesh.model.validators.PresenceValidator;
	
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
		
		override public function translateFrom(object:Object):void
		{
			copy(object, this);
		}
		
		override public function translateTo():*
		{
			var obj:Object = {};
			copy(this, obj, {includes:["id", "age", "name"]});
			return obj;
		}
	}
}