package mesh.models
{
	import mesh.Entity;
	import mesh.core.object.copy;
	import mesh.validators.LengthValidator;
	import mesh.validators.NumericValidator;
	import mesh.validators.PresenceValidator;
	
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
			copy(this, obj, {includes:["age", "name"]});
			return obj;
		}
	}
}