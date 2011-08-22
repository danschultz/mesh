package mesh.model.store
{
	import mesh.Account;
	import mesh.Customer;
	import mesh.Name;
	import mesh.Order;
	import mesh.model.Entity;
	import mesh.model.source.FixtureSource;
	import mesh.model.source.MultiSource;
	
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
			
			assertThat(customer.id, notNullValue());
			assertThat(customer.hasPropertyChanges, equalTo(false));
			assertThat(customer.state, equalTo(Entity.PERSISTED | Entity.SYNCED));
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
			
			assertThat(customer.hasPropertyChanges, equalTo(false));
			assertThat(customer.state, equalTo(Entity.PERSISTED | Entity.SYNCED));
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
			
			assertThat(customer.state, equalTo(Entity.DESTROYED | Entity.SYNCED));
		}
	}
}