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
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.hasProperty;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;
	
	[Ignore]
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
			
			//var store:Store = new Store(new TestSource());
			//store.add(_customer);
			//store.commit();
		}
		
		[Test]
		public function testSerializeUnnested():void
		{
			var serialized:Object = null;//_customer.serialize({});
			
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
			var serialized:Object = null;//_customer.serialize({only:["age"]});
			
			assertThat(serialized.id, nullValue());
			assertThat(serialized.age, equalTo(_customer.age));
		}
		
		[Test]
		public function testSerializeExclude():void
		{
			var serialized:Object = null;//_customer.serialize({exclude:["age"]});
			
			assertThat(serialized.id, equalTo(_customer.id));
			assertThat(serialized.age, nullValue());
		}
		
		[Test]
		public function testSerializeWithMapping():void
		{
			var serialized:Object = null;//_customer.serialize({
			//	includes:{orders:true},
			//	mapping:{age:"yearsOld", orders:"purchases"}
			//});
			
			assertThat(serialized.age, nullValue());
			assertThat(serialized.yearsOld, notNullValue());
			assertThat(serialized.orders, nullValue());
			assertThat(serialized.purchases, notNullValue());
		}
		
		[Test]
		public function testSerializeNested():void
		{
			var serialized:Object = null;//_customer.serialize({
			//	includes:{
			//		name:true,
			//		address:{only:["street"]},
			//		orders:{
			//			includes:{
			//				shippingAddress:true
			//			}
			//		}
			//	}
			//});
				
			assertThat(serialized.id, equalTo(_customer.id));
			assertThat(serialized.age, equalTo(_customer.age));
			assertThat(serialized.name, hasProperties({first:_customer.name.first, last:_customer.name.last}));
			assertThat(serialized.address, hasProperties({street:_customer.address.street}));
			assertThat(serialized.address.city, nullValue());
			assertThat(serialized.account, nullValue());
			assertThat(serialized.orders, array(hasProperties({total:5}), hasProperties({total:10})));
		}
		
		[Test]
		public function testSerializeNestedAssociations():void
		{
			var serialized:Object = null;//_customer.serialize({
			//	includes:{account:true, orders:true}
			//});
			
			assertThat(serialized.account, allOf(not(hasProperty("storeKey")), hasPropertyWithValue("number", _customer.account.number)));
			assertThat(serialized.orders, array(allOf(not(hasProperty("storeKey")), hasProperties({total:5})), allOf(not(hasProperty("storeKey")), hasProperties({total:10}))));
		}
	}
}