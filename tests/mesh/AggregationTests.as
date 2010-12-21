package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import mx.events.PropertyChangeEvent;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.everyItem;
	import org.hamcrest.collection.hasItems;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
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
		
		[Test]
		public function testAggregateDispatchesPropertyChange():void
		{
			var changeEvent:PropertyChangeEvent;
			_entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function(event:PropertyChangeEvent):void
			{
				changeEvent = event;
			});
			_entity.addressStreet = "1 Infinite Loop";
			assertThat(changeEvent.property, equalTo("address"));
		}
		
		[Test]
		public function testAggregateDoesNotDispatchPropertyChangesWhenBindableIsFalse():void
		{
			var changeEvent:PropertyChangeEvent;
			_entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function(event:PropertyChangeEvent):void
			{
				changeEvent = event;
			});
			_entity.latitude = 10;
			assertThat(changeEvent, nullValue());
		}
		
		[Test]
		public function testEntityContainsAggregateProperties():void
		{
			var tests:Array = [{instance:new Customer(), expects:["address", "addressStreet", "addressCity", "fullName", "firstName", "lastName", "location", "latitude", "longitude"]}];
			
			for each (var test:Object in tests) {
				var properties:Array = test.instance.properties.toArray();
				assertThat("test failed for " + test.expects, properties, everyItem(isA(String)));
				assertThat("test failed for " + test.expects, properties, hasItems.apply(null, test.expects));
			}
		}
	}
}