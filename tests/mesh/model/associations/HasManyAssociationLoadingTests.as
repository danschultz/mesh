package mesh.model.associations
{
	import mesh.Organization;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;
	
	[Ignore]
	public class HasManyAssociationLoadingTests
	{
		//private var _store:Store;
		private var _organization:Organization;
		
		[Before]
		public function setup():void
		{
			/*
			var dataSource:TestSource = new TestSource();
			
			var store:Store = new Store(dataSource);
			_organization = store.create(Organization, {name:"Apple"});
			_organization.employees = new ArrayList([store.create(Employee, {name: new Name("Steve", "Jobs")})]);
			store.commit();
			
			_store = new Store(dataSource);
			*/
		}
		
		[Test]
		public function testLoadLazyAssociation():void
		{
			var organization:Organization = null;//_store.find(Organization, _organization.id);
			
			assertThat("Precondition failed", organization.employees, nullValue());
			
			organization.associations.employees.load().request();
			assertThat(organization.employees, notNullValue());
			assertThat(organization.associations.employees.isLoaded, equalTo(true));
			//assertThat(_store.hasChanges, equalTo(false));
		}
	}
}