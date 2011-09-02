package mesh.model
{
	import mesh.Name;

	public class AggregateTestMockEntity extends Entity
	{
		[Bindable] public var name:Name;
		[Bindable] public var firstName:String;
		[Bindable] public var last:String;
		
		public function AggregateTestMockEntity(values:Object=null)
		{
			super(values);
			aggregate("name", Name, ["first:firstName", "last"]);
		}
	}
}