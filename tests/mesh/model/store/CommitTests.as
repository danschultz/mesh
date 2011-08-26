package mesh.model.store
{
	import mesh.Account;
	import mesh.Customer;
	import mesh.Name;
	import mesh.Order;
	import mesh.model.Entity;
	import mesh.model.source.FixtureSource;
	import mesh.model.source.MultiSource;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;

	public class CommitTests
	{
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			var multiSource:MultiSource = new MultiSource();
			multiSource.map(Customer, new FixtureSource(Customer, {latency:0}));
			multiSource.map(Account, new FixtureSource(Account, {latency:0}));
			multiSource.map(Order, new FixtureSource(Order, {latency:0}));
			
			_store = new Store(multiSource);
		}
		
		private function checkIfPersisted(entity:Entity):void
		{
			assertThat(entity.id, notNullValue());
			assertThat(entity.hasPropertyChanges, equalTo(false));
			assertThat(entity.status.isPersisted && entity.status.isSynced, equalTo(true));
		}
		
		private function createCustomer(properties:Object):Customer
		{
			var customer:Customer = new Customer(properties);
			_store.add(customer);
			_store.commit();
			return customer;
		}
		
		[Test]
		public function testCreate():void
		{
			var customer:Customer = createCustomer({
				name: new Name("Jimmy", "Page"),
				age: 67
			});
			
			checkIfPersisted(customer);
		}
		
		[Test]
		public function testCreateGraph():void
		{
			var customer:Customer = createCustomer({
				name: new Name("Jimmy", "Page"),
				age: 67,
				orders: new ArrayList([
					new Order({
						total:5
					}),
					new Order({
						total:10
					})
				]),
				account: new Account({number:"001-001"})
			});
			
			checkIfPersisted(customer);
			checkIfPersisted(customer.account);
			for each (var order:Order in customer.orders.toArray()) {
				checkIfPersisted(order);
			}
		}
		
		[Test]
		public function testUpdate():void
		{
			var customer:Customer = createCustomer({
				name: new Name("Jimmy", "Page"),
				age: 67
			});
			
			customer.age = 68;
			_store.commit();
			
			checkIfPersisted(customer);
		}
		
		[Test]
		public function testDestroy():void
		{
			var customer:Customer = createCustomer({
				name: new Name("Jimmy", "Page"),
				age: 67
			});
			
			customer.destroy();
			_store.commit();
			
			assertThat(customer.status.isDestroyed && customer.status.isSynced, equalTo(true));
		}
	}
}