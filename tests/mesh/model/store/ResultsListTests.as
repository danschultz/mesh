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
		private var _person:Object;
		private var _fixtures:FixtureDataSource;
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			_person = {id:1, firstName:"Jimmy", lastName:"Page"};
			_fixtures = new FixtureDataSource(Person);
			_store = new Store(_fixtures);
		}
		
		[Test]
		public function testLoad():void
		{
			var called:Boolean;
			var results:ResultsList = new ResultsList(_store, new ArrayList(), new MethodOperation(function():void
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
			var results:ResultsList = new ResultsList(_store, new ArrayList(), new MethodOperation(function():void
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
			var results:ResultsList = new ResultsList(_store, new ArrayList(), new MethodOperation(function():void
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