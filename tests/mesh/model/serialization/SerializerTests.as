package mesh.model.serialization
{
	import mesh.Account;
	import mesh.Address;
	import mesh.Customer;
	import mesh.Name;
	import mesh.Order;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.nullValue;

	public class SerializerTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer({
				id:1,
				age: 67,
				name: new Name("Jimmy", "Page"),
				address: new Address("2306 Zanker Rd", "San Jose"),
				account: new Account({
					number:"001-001"
				}),
				orders: new ArrayList([
					new Order({
						total:5
					}),
					new Order({
						total:10
					})
				])
			});
		}
		
		[Test]
		public function testSerializeUnnested():void
		{
			var serialized:Object = _customer.serialize();
			
			assertThat(serialized.id, equalTo(_customer.id));
			assertThat(serialized.age, equalTo(_customer.age));
			assertThat(serialized.name, nullValue());
			assertThat(serialized.address, nullValue());
			assertThat(serialized.account, nullValue());
			assertThat(serialized.orders, nullValue());
		}
		
		[Test]
		public function testSerializeOnly():void
		{
			var serialized:Object = _customer.serialize({only:["age"]});
			
			assertThat(serialized.id, nullValue());
			assertThat(serialized.age, equalTo(_customer.age));
		}
		
		[Test]
		public function testSerializeExclude():void
		{
			var serialized:Object = _customer.serialize({exclude:["age"]});
			
			assertThat(serialized.id, equalTo(_customer.id));
			assertThat(serialized.age, nullValue());
		}
		
		[Test]
		public function testSerializeNested():void
		{
			var serialized:Object = _customer.serialize({
				includes:{
					name:{
						only:["firstName", "lastName"]
					},
					address:{only:["street"]},
					orders:{
						includes:{
							shippingAddress:true
						}
					}
				}
			});
				
			assertThat(serialized.id, equalTo(_customer.id));
			assertThat(serialized.age, equalTo(_customer.age));
			assertThat(serialized.name, hasProperties({firstName:_customer.name.firstName, lastName:_customer.name.lastName}));
			assertThat(serialized.address, hasProperties({street:_customer.address.street}));
			assertThat(serialized.address.city, nullValue());
			assertThat(serialized.account, nullValue());
			assertThat(serialized.orders, array(hasProperties({total:5}), hasProperties({total:10})));
		}
	}
}