package mesh.model
{
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.store.Data;
	import mesh.model.store.Store;
	import mesh.operations.OperationEvent;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;

	public class RecordLoadTests
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
		 * Make sure that load() will load the data for the record.
		 */
		public function testLoad():void
		{
			var person:Person = _store.materialize(new Data({id:_data.id}, Person));
			person.load();
			
			assertThat(person, hasProperties(_data));
			assertThat(person.isLoaded, equalTo(true));
		}
		
		[Test]
		/**
		 * Make sure that multiple calls to load() will no reload the entity.
		 */
		public function testOnlyLoadOnce():void
		{
			var person:Person = _store.materialize(new Data({id:_data.id}, Person));
			person.load();
			
			var reloaded:Boolean;
			person.loadOperation.addEventListener(OperationEvent.BEFORE_EXECUTE, function(event:OperationEvent):void
			{
				reloaded = true;
			});
			
			assertThat(reloaded, equalTo(false));
		}
		
		[Test]
		public function testRefresh():void
		{
			var person:Person = _store.materialize(new Data({id:_data.id}, Person));
			person.load();
			
			_data = {id:1, firstName:"Fox", lastName:"Mulder"};
			_fixtures.add(_data);
			person.refresh();
			
			assertThat(person, hasProperties(_data));
		}
	}
}