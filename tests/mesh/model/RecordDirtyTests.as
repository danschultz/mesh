package mesh.model
{
	import mesh.Name;
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class RecordDirtyTests
	{
		private var _data:Object;
		private var _fixtures:FixtureDataSource;
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			_data = {id:1, firstName:"Jimmy", lastName:"Page"};
			_fixtures = new FixtureDataSource(Person);
			_fixtures.add(_data);
			_store = new Store(_fixtures);
		}
		
		[Test]
		/**
		 * Make sure that changing a property of a record marks it as dirty.
		 */
		public function testPropertyChange():void
		{
			var person:Person = _store.query(Person).find(1).load();
			person.name = new Name("Steve", "Jobs");
			
			assertThat(person.changes.hasChanges, equalTo(true));
			assertThat(person.state.isRemote, equalTo(true));
			assertThat(person.state.isSynced, equalTo(false));
		}
	}
}