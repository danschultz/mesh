package mesh
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;

	public class AggregationTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
		}
		
		[Test]
		public function testSetAggregateOnEntity():void
		{
			_customer.address = new Address("2306 Zanker Rd", "San Jose");
			assertThat(_customer.address.equals(new Address("2306 Zanker Rd", "San Jose")), equalTo(true));
		}
		
		[Test]
		public function testSetAggregatePrefixedProperty():void
		{
			_customer.addressStreet = "2306 Zanker Rd";
			_customer.addressCity = "San Jose";
			assertThat(_customer.address.equals(new Address("2306 Zanker Rd", "San Jose")), equalTo(true));
		}
		
		[Test]
		public function testGetAggregatePrefixedProperty():void
		{
			_customer.addressStreet = "2306 Zanker Rd";
			_customer.addressCity = "San Jose";
			assertThat(_customer.addressStreet, equalTo("2306 Zanker Rd"));
			assertThat(_customer.addressCity, equalTo("San Jose"));
		}
		
		[Test]
		public function testSetAggregateNonPrefixedProperty():void
		{
			_customer.streetAddress = "2306 Zanker Rd";
			_customer.cityAddress = "San Jose";
			assertThat(_customer.address2.equals(new Address("2306 Zanker Rd", "San Jose")), equalTo(true));
		}
		
		[Test]
		public function testGetAggregateNonPrefixedProperty():void
		{
			_customer.streetAddress = "2306 Zanker Rd";
			_customer.cityAddress = "San Jose";
			assertThat(_customer.streetAddress, equalTo("2306 Zanker Rd"));
			assertThat(_customer.cityAddress, equalTo("San Jose"));
		}
		
		[Test]
		public function testGetAggregatePropertyNull():void
		{
			assertThat(_customer.addressStreet, nullValue());
		}
	}
}