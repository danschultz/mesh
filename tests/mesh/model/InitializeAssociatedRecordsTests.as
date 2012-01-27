package mesh.model
{
	import mesh.Customer;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.notNullValue;

	public class InitializeAssociatedRecordsTests
	{
		private var _data:Object;
		private var _fixtures:FixtureDataSource;
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			_data = {id:1, firstName:"Jimmy", lastName:"Page", accountId:1};
			_fixtures = new FixtureDataSource(Customer);
			_fixtures.add(_data);
			_store = new Store(_fixtures);
		}
		
		[Test]
		public function testInitializeHasOneAssociation():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			assertThat(customer.account, notNullValue());
		}
	}
}