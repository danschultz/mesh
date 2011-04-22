package mesh.model
{
	import mesh.Name;

	public class AggregateTestMockEntity extends Entity
	{
		[Bindable] public var name:Name;
		[Bindable] public var firstName:String;
		[Bindable] public var lastName:String;
		
		public function AggregateTestMockEntity(values:Object=null)
		{
			super(values);
			aggregate("name", Name, ["firstName", "lastName"]);
		}
	}
}