package mesh.model
{
	import mesh.Name;

	public class AggregateTestMockRecord extends Record
	{
		[Bindable] public var name:Name;
		[Bindable] public var firstName:String;
		[Bindable] public var last:String;
		
		public function AggregateTestMockRecord(values:Object=null)
		{
			super(values);
			aggregate("name", Name, ["first:firstName", "last"]);
		}
	}
}