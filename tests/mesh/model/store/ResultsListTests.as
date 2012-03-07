package mesh.model.store
{
	import mesh.Person;
	import mesh.model.source.FixtureDataSource;
	import mesh.operations.MethodOperation;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class ResultsListTests
	{
		private var _fixtures:FixtureDataSource;
		private var _records:RecordCache;
		
		[Before]
		public function setup():void
		{
			_fixtures = new FixtureDataSource(Person);
			_records = new RecordCache(new Store(_fixtures), _fixtures, new DataCache());
		}
		
		[Test]
		public function testLoad():void
		{
			var called:Boolean;
			var results:ResultsList = new ResultsList(_records, new ArrayList(), new MethodOperation(function():void
			{
				called = true;
			}));
			results.load();
			
			assertThat(called, equalTo(true));
			assertThat(results.isLoaded, equalTo(true));
		}
		
		[Test]
		public function testLoadOnlyOnce():void
		{
			var called:Boolean;
			var results:ResultsList = new ResultsList(_records, new ArrayList(), new MethodOperation(function():void
			{
				called = true;
			}));
			results.load();
			
			called = false;
			results.load();
			
			assertThat(called, equalTo(false));
		}
		
		[Test]
		public function testRefresh():void
		{
			var called:Boolean;
			var results:ResultsList = new ResultsList(_records, new ArrayList(), new MethodOperation(function():void
			{
				called = true;
			}));
			results.load();
			
			called = false;
			results.refresh();
			
			assertThat(called, equalTo(true));
		}
	}
}