package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;

	public class AggregationTests
	{
		private var _entity:Customer;
		
		[Before]
		public function setup():void
		{
			_entity = new Customer();
		}
		
		[Test]
		public function testSetAggregateOnEntity():void
		{
			var address:Address = new Address("2306 Zanker Rd", "San Jose");
			_entity.address = address;
			assertThat(_entity.address.equals(address), equalTo(true));
		}
		
		[Test]
		public function testSetAggregatePrefixedProperty():void
		{
			var address:Address = new Address("2306 Zanker Rd", "San Jose");
			_entity.addressStreet = "2306 Zanker Rd";
			_entity.addressCity = "San Jose";
			assertThat(_entity.address.equals(address), equalTo(true));
		}
		
		[Test]
		public function testGetAggregatePrefixedProperty():void
		{
			_entity.addressStreet = "2306 Zanker Rd";
			_entity.addressCity = "San Jose";
			assertThat(_entity.addressStreet, equalTo("2306 Zanker Rd"));
			assertThat(_entity.addressCity, equalTo("San Jose"));
		}
		
		[Test]
		public function testSetAggregateNonPrefixedProperty():void
		{
			var name:Name = new Name("John", "Doe");
			_entity.firstName = name.firstName;
			_entity.lastName = name.lastName;
			assertThat(_entity.fullName.equals(name), equalTo(true));
		}
		
		[Test]
		public function testGetAggregateNonPrefixedProperty():void
		{
			var name:Name = new Name("John", "Doe");
			_entity.firstName = name.firstName;
			_entity.lastName = name.lastName;
			assertThat(_entity.firstName, equalTo(name.firstName));
			assertThat(_entity.lastName, equalTo(name.lastName));
		}
		
		[Test]
		public function testGetAggregatePropertyNull():void
		{
			assertThat(_entity.addressStreet, nullValue());
		}
	}
}