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

	public class HasOneAssociationLoadingTests
	{
		private var _store:Store;
		private var _employee:Employee;
		
		[Before]
		public function setup():void
		{
			var dataSource:TestSource = new TestSource();
			
			_employee = new Employee({name:new Name("Steve", "Jobs")});
			var organization:Organization = new Organization({
				name:"Apple",
				employees:new ArrayList([_employee])
			});
			
			var store:Store = new Store(dataSource);
			store.add(organization);
			store.commit();
			
			_store = new Store(dataSource);
		}
		
		[Test]
		public function testLoadLazyAssociation():void
		{
			var employee:Employee;
			_store.find(Employee, _employee.id).responder({
				result:function(data:Employee):void
				{
					employee = data;
				}
			}).request();
			
			assertThat("Precondition failed", employee.employer, nullValue());
			
			employee.associations.employer.load().request();
			assertThat(employee.employer, notNullValue());
			assertThat(employee.associations.employer.isLoaded, equalTo(true));
		}
	}
}