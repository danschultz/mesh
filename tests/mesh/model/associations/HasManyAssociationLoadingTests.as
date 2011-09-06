package mesh.model.associations
{
	import mesh.Employee;
	import mesh.Name;
	import mesh.Organization;
	import mesh.TestSource;
	import mesh.model.store.Store;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;

	public class HasManyAssociationLoadingTests
	{
		private var _store:Store;
		private var _organization:Organization;
		
		[Before]
		public function setup():void
		{
			var dataSource:TestSource = new TestSource();
			
			_organization = new Organization({
				name:"Apple",
				employees:new ArrayList([
					new Employee({name:new Name("Steve", "Jobs")})
				])
			});
			
			var store:Store = new Store(dataSource);
			store.add(_organization);
			store.commit();
			
			_store = new Store(dataSource);
		}
		
		[Test]
		public function testLoadLazyAssociation():void
		{
			var organization:Organization;
			_store.find(Organization, _organization.id).responder({
				result:function(data:Organization):void
				{
					organization = data;
				}
			}).request();
			
			assertThat("Precondition failed", organization.employees, nullValue());
			
			organization.associations.employees.load().request();
			assertThat(organization.employees, notNullValue());
			assertThat(organization.associations.employees.isLoaded, equalTo(true));
		}
	}
}