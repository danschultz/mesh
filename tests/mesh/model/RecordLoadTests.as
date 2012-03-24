package mesh.model
{
	import mesh.AsyncTest;
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.store.Store;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.OperationEvent;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;

	public class RecordLoadTests
	{
		private static const LATENCY:int = 100;
		
		private var _data:Object;
		private var _fixtures:FixtureDataSource;
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			_data = {id:1, firstName:"Jimmy", lastName:"Page"};
			_fixtures = new FixtureDataSource(Person, {latency:LATENCY});
			_fixtures.add(_data);
			_store = new Store(_fixtures);
		}
		
		private function assertRecordLoaded(record:Record, data:Object):void
		{
			assertThat(record, hasProperties(data));
			assertThat(record.isLoaded, equalTo(true));
			assertThat(record.state.isRemote, equalTo(true));
		}
		
		[Test(async)]
		/**
		 * Make sure that load() will load the data for the record.
		 */
		public function testLoad():void
		{
			var test:AsyncTest = new AsyncTest(this, LATENCY+100, function():void
			{
				assertRecordLoaded(person, _data);
			});
			
			var person:Person = _store.query(Person).find(1);
			person.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				if (event.successful) {
					test.complete();
				}
			});
			person.load();
			
			assertThat(person.state.isBusy, equalTo(true));
		}
		
		[Test(async)]
		/**
		 * Make sure that multiple calls to load() will no reload the entity.
		 */
		public function testOnlyLoadOnce():void
		{
			var test:AsyncTest = new AsyncTest(this, LATENCY+100, function():void
			{
				assertThat(loadCount, equalTo(1));
			});
			
			var loadCount:int = 0;
			var person:Person = _store.query(Person).find(1);
			person.loadOperation.addEventListener(OperationEvent.BEFORE_EXECUTE, function(event:OperationEvent):void
			{
				++loadCount;
			});
			person.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				if (event.successful) {
					person.load();
					test.complete();
				}
			});
			person.load();
		}
		
		[Test(async)]
		public function testRefresh():void
		{
			var test:AsyncTest = new AsyncTest(this, LATENCY+100, function():void
			{
				assertRecordLoaded(person, data);
			});
			
			var person:Person = _store.query(Person).find(1);
			var data:Object = {id:1, firstName:"Steve", lastName:"Jobs"};
			_fixtures.add(data);
			
			person.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				if (event.successful) {
					test.complete();
				}
			});
			person.refresh();
			
			assertThat(person.state.isBusy, equalTo(true));
		}
	}
}