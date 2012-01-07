package mesh.model.store
{
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;

	public class FindTests
	{
		[Test]
		public function testFindRecordThroughDataSource():void
		{
			var data:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var fixtures:FixtureDataSource = new FixtureDataSource(Person);
			fixtures.add(data);
			var store:Store = new Store(fixtures);
			var person:Person = store.find(Person, 1);
			assertThat(person, hasProperties(data));
		}
		
		[Test]
		public function testFindRecordThroughDataBelongingToStore():void
		{
			var data:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var store:Store = new Store(new FixtureDataSource(Person));
			store.data.add( new Data(data, Person) );
			var person:Person = store.find(Person, 1);
			assertThat(person, hasProperties(data));
		}
		
		[Test]
		public function testFindRecordAlwaysReturnsSameRecord():void
		{
			var data:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var fixtures:FixtureDataSource = new FixtureDataSource(Person);
			fixtures.add(data);
			
			var store:Store = new Store(fixtures);
			var person1:Person = store.find(Person, 1);
			var person2:Person = store.find(Person, 1);
			assertThat(person1, equalTo(person2));
		}
	}
}