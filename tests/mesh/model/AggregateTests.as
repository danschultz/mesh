package mesh.model
{
	import mesh.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class AggregateTests
	{
		private var _entity:AggregateTestMockEntity;
		
		[Before]
		public function setup():void
		{
			_entity = new AggregateTestMockEntity();
		}
		
		[Test]
		public function testPropertyChangeUpdatesAggregate():void
		{
			_entity.firstName = "Thom";
			_entity.last = "Yorke";
			assertThat(_entity.name.first, equalTo(_entity.firstName));
			assertThat(_entity.name.last, equalTo(_entity.last));
		}
		
		[Test]
		public function testAggregateChangeUpdatesProperties():void
		{
			_entity.name = new Name("Thom", "Yorke");
			assertThat(_entity.firstName, equalTo(_entity.name.first));
			assertThat(_entity.last, equalTo(_entity.name.last));
		}
	}
}
