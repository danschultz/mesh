package mesh.model
{
	import mesh.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class AggregateTests
	{
		private var _record:AggregateTestMockRecord;
		
		[Before]
		public function setup():void
		{
			_record = new AggregateTestMockRecord();
		}
		
		[Test]
		public function testPropertyChangeUpdatesAggregate():void
		{
			_record.firstName = "Thom";
			_record.last = "Yorke";
			assertThat(_record.name.first, equalTo(_record.firstName));
			assertThat(_record.name.last, equalTo(_record.last));
		}
		
		[Test]
		public function testAggregateChangeUpdatesProperties():void
		{
			_record.name = new Name("Thom", "Yorke");
			assertThat(_record.firstName, equalTo(_record.name.first));
			assertThat(_record.last, equalTo(_record.name.last));
		}
	}
}
