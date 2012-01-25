package mesh.model.store
{
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	
	import mx.collections.IList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.hasItems;
	import org.hamcrest.core.allOf;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;

	public class QueryTests
	{
		[Test]
		public function testFindRecord():void
		{
			var data:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var fixtures:FixtureDataSource = new FixtureDataSource(Person);
			fixtures.add(data);
			var store:Store = new Store(fixtures);
			var person:Person = store.query(Person).find(1).load();
			assertThat(person, hasProperties(data));
		}
		
		[Test]
		public function testFindAlwaysReturnsSameRecord():void
		{
			var data:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var fixtures:FixtureDataSource = new FixtureDataSource(Person);
			fixtures.add(data);
			
			var store:Store = new Store(fixtures);
			var person1:Person = store.query(Person).find(1).load();
			var person2:Person = store.query(Person).find(1).load();
			assertThat(person1, equalTo(person2));
		}
		
		[Test]
		public function testFindAllRecords():void
		{
			var person1:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var person2:Object = {id:2, firstName:"Fox", lastName:"Mulder"};
			
			var fixtures:FixtureDataSource = new FixtureDataSource(Person);
			fixtures.add(person1);
			fixtures.add(person2);
			
			var store:Store = new Store(fixtures);
			var people:IList = store.query(Person).findAll().load();
			assertThat(people.toArray(), allOf(arrayWithSize(2), hasItems(hasProperties(person1), hasProperties(person2))));
		}
	}
}