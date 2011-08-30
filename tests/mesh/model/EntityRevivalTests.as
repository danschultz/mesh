package mesh.model
{
	import mesh.Name;
	import mesh.Person;
	import mesh.TestSource;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class EntityRevivalTests
	{
		private var _person:Person;
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			_person = new Person({name:new Name("Jimmy", "Page"), age:67});
			
			_store = new Store(new TestSource());
			_store.add(_person);
			_store.commit();
		}
		
		[Test]
		public function testStatusIsNewIfRevivedWithoutID():void
		{
			var person:Person = new Person({name:new Name("Steve", "Jobs")});
			_store.add(person);
			
			person.destroy();
			person.revive();
			assertThat(person.status.isNew, equalTo(true));
		}
		
		[Test]
		public function testStatusIsPersistedAndDirtyIfRevivedWithPropertyChanges():void
		{
			_person.age++;
			
			_person.destroy();
			_person.revive();
			assertThat(_person.status.isPersisted && _person.status.isDirty, equalTo(true));
		}
		
		[Test]
		public function testStatusIsPersistedAndSyncedIfNoPropertyChanges():void
		{
			_person.destroy();
			_person.revive();
			assertThat(_person.status.isPersisted && !_person.status.isDirty, equalTo(true));
		}
		
		[Test]
		public function testStatusIsNewIfDestroyedAndSynced():void
		{
			_person.destroy();
			_store.commit();
			
			_person.revive();
			assertThat(_person.id, equalTo(null));
			assertThat(_person.status.isNew, equalTo(true));
		}
	}
}