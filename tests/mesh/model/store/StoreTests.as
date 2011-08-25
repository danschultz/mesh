package mesh.model.store
{
	import mesh.Person;
	import mesh.model.source.FixtureSource;
	import mesh.model.source.MultiSource;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.notNullValue;

	public class StoreTests
	{
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			var multiSource:MultiSource = new MultiSource();
			multiSource.map(Person, new FixtureSource(Person, {latency:0}));
			_store = new Store(multiSource);
		}
		
		[Test]
		[Ignore("The try..catch block isn't catching the error and the test case isn't failing.")]
		public function testAddingEntityToStoreThrowsErrorWithDuplicateEntry():void
		{
			var person:Person = new Person();
			_store.add(person);
			_store.commit();
			
			var duplicate:Person = new Person(person.serialize());
			
			var error:Error;
			try {
				_store.add(duplicate);
			} catch (e:Error) {
				error = e;
			}
			assertThat(error, notNullValue());
		}
		
		[Test]
		[Ignore("The try..catch block isn't catching the error and the test case isn't failing.")]
		public function testUpdatingEntityIDThrowsErrorWithDuplicateEntry():void
		{
			var person:Person = new Person();
			_store.add(person);
			_store.commit();
			
			var duplicate:Person = new Person();
			_store.add(duplicate);
			
			var error:Error;
			try {
				duplicate.id = person.id;
			} catch (e:Error) {
				error = e;
			}
			assertThat(error, notNullValue());
		}
	}
}