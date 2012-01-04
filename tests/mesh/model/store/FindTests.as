package mesh.model.store
{
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.hasProperties;

	public class FindTests
	{
		[Test]
		public function testFindEntity():void
		{
			var data:Object = {id:1, firstName:"Jimmy", lastName:"Page"};
			var fixtures:FixtureDataSource = new FixtureDataSource(Person);
			fixtures.add(data);
			var store:Store = new Store(fixtures);
			var person:Person = store.find(Person, 1);
			assertThat(person, hasProperties(data));
		}
	}
}