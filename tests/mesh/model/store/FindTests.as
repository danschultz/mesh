package mesh.model.store
{
	import mesh.Account;
	import mesh.Customer;
	import mesh.Name;
	import mesh.Order;
	import mesh.Person;
	import mesh.TestSource;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.hasPropertyWithValue;

	public class FindTests
	{
		private var _jimmyPage:Person;
		private var _robertPlant:Person;
		private var _customer:Customer;
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			_jimmyPage = new Person({
				age: 67,
				name: new Name("Jimmy", "Page")
			});
			_robertPlant = new Person({
				age: 63,
				name: new Name("Robert", "Plant")
			});
			
			_customer = new Customer({
				name: new Name("John", "Doe"),
				account: new Account({number:"001-001"}),
				orders: new ArrayList([
					new Order({total:5}),
					new Order({total:10})
				])
			});
			
			var dataSource:TestSource = new TestSource();
			
			var tempStore:Store = new Store(dataSource);
			tempStore.add(_jimmyPage);
			tempStore.add(_robertPlant);
			tempStore.add(_customer);
			tempStore.commit();
			
			// Start fresh with an empty store.
			_store = new Store(dataSource);
		}
		
		[Test]
		public function testFindEntity():void
		{
			var person:Person = _store.find(Person, _jimmyPage.id);
			
			assertThat(_store.entities.contains(person), equalTo(true));
			assertThat(person.id, equalTo(_jimmyPage.id));
			assertThat(person.name, hasProperties({first:_jimmyPage.name.first, last:_jimmyPage.name.last}));
			assertThat(person.status.isSynced, equalTo(true));
			assertThat(_store.hasChanges, equalTo(false));
		}
		
		[Test]
		public function testFindEntityWithNonLazyAssociationsDoesNotMarkStoreAsDirty():void
		{
			var customer:Customer = _store.find(Customer, _customer.id);
			
			assertThat(_store.hasChanges, equalTo(false));
		}
		
		[Test]
		public function testFindQuery():void
		{
			var result:ResultList = _store.find(new LocalQuery().on(Person));
			
			var results:Array = result.toArray();
			assertThat(results.length, equalTo(2));
			assertThat(results, array(hasProperties({id:_jimmyPage.id, name:hasProperties({first:_jimmyPage.name.first, last:_jimmyPage.name.last}), status:hasPropertyWithValue("isSynced", true)}),
									  hasProperties({id:_robertPlant.id, name:hasProperties({first:_robertPlant.name.first, last:_robertPlant.name.last}), status:hasPropertyWithValue("isSynced", true)})));
			assertThat(_store.hasChanges, equalTo(false));
		}
	}
}