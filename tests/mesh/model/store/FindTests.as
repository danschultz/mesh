package mesh.model.store
{
	import mesh.Name;
	import mesh.Person;
	import mesh.TestSource;
	
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
			
			var dataSource:TestSource = new TestSource();
			
			var tempStore:Store = new Store(dataSource);
			tempStore.add(_jimmyPage);
			tempStore.add(_robertPlant);
			tempStore.commit();
			
			// Start fresh with an empty store.
			_store = new Store(dataSource);
		}
		
		[Test]
		public function testFindEntity():void
		{
			var customer:Person;
			_store.find(Person, _jimmyPage.id).responder({
				result:function(data:Person):void
				{
					customer = data;
				}
			}).request();
			
			assertThat(_store.index.contains(customer), equalTo(true));
			assertThat(customer.id, equalTo(_jimmyPage.id));
			assertThat(customer.name, hasProperties({first:_jimmyPage.name.first, last:_jimmyPage.name.last}));
		}
		
		[Test]
		public function testFindQuery():void
		{
			var result:ResultList;
			_store.find(new LocalQuery().on(Person)).responder({
				result:function(data:ResultList):void
				{
					result = data;
				}
			}).request();
			
			var results:Array = result.toArray();
			assertThat(results.length, equalTo(2));
			assertThat(results, array(hasProperties({id:_jimmyPage.id, name:hasProperties({first:_jimmyPage.name.first, last:_jimmyPage.name.last})}),
									  hasProperties({id:_robertPlant.id, name:hasProperties({first:_robertPlant.name.first, last:_robertPlant.name.last})})));
		}
	}
}