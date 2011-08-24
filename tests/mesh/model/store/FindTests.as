package mesh.model.store
{
	import mesh.Name;
	import mesh.Person;
	import mesh.model.source.FixtureSource;
	import mesh.model.source.MultiSource;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;

	public class FindTests
	{
		private var _jimmyPage:Person;
		private var _robertPlant:Person;
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
			
			var multiSource:MultiSource = new MultiSource();
			multiSource.map(Person, new FixtureSource(Person, {latency:0}));
			
			var tempStore:Store = new Store(multiSource);
			tempStore.add(_jimmyPage);
			tempStore.add(_robertPlant);
			tempStore.commit();
			
			// Start fresh with an empty store.
			_store = new Store(multiSource);
		}
		
		[Test]
		public function testFindEntity():void
		{
			var customer:Person = _store.find(Person, _jimmyPage.id);
			assertThat(customer.id, equalTo(_jimmyPage.id));
			assertThat(customer.name, hasProperties({firstName:_jimmyPage.name.firstName, lastName:_jimmyPage.name.lastName}));
		}
		
		[Test]
		public function testFindQuery():void
		{
			var result:ResultList = _store.find(new LocalQuery().on(Person));
			var results:Array = result.toArray();
			assertThat(results.length, equalTo(2));
			assertThat(results, array(hasProperties({id:_jimmyPage.id, name:hasProperties({firstName:_jimmyPage.name.firstName, lastName:_jimmyPage.name.lastName})}),
									  hasProperties({id:_robertPlant.id, name:hasProperties({firstName:_robertPlant.name.firstName, lastName:_robertPlant.name.lastName})})));
		}
	}
}