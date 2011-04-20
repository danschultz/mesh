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
			_entity.lastName = "Yorke";
			assertThat(_entity.name.firstName, equalTo(_entity.firstName));
			assertThat(_entity.name.lastName, equalTo(_entity.lastName));
		}
		
		[Test]
		public function testAggregateChangeUpdatesProperties():void
		{
			_entity.name = new Name("Thom", "Yorke");
			assertThat(_entity.firstName, equalTo(_entity.name.firstName));
			assertThat(_entity.lastName, equalTo(_entity.name.lastName));
		}
	}
}
