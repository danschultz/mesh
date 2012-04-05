package mesh.model
{
	import mesh.AsyncTest;
	import mesh.Customer;
	import mesh.Name;
	import mesh.Order;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.source.MultiDataSource;
	import mesh.model.store.CommitResponder;
	import mesh.model.store.Store;
	import mesh.operations.FinishedOperationEvent;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class RecordCommitTests
	{
		private static const LATENCY:int = 100;
		
		private var _store:Store;
		private var _dataSources:MultiDataSource;
		
		[Before]
		public function setup():void
		{
			var customers:FixtureDataSource = new FixtureDataSource(Customer, {latency:LATENCY});
			customers.add({id:1, firstName:"Jimmy", lastName:"Page", accountId:1});
			
			var orders:FixtureDataSource = new FixtureDataSource(Order, {latency:LATENCY});
			orders.add({id:1, customerId:1});
			orders.add({id:2, customerId:1});
			orders.add({id:3, customerId:1});
			
			_dataSources = new MultiDataSource();
			_dataSources.map(Customer, customers);
			_dataSources.map(Order, orders);
			
			_store = new Store(_dataSources);
		}
		
		private function assertIsSynced(record:Record, isRemote:Boolean):void
		{
			assertThat(ID.isPopulated(record), equalTo(true));
			assertThat(record.state.isRemote, equalTo(isRemote));
			assertThat(record.state.isSynced, equalTo(true));
		}
		
		[Test(async)]
		public function testCreate():void
		{
			var test:AsyncTest = new AsyncTest(this, LATENCY+100, function():void
			{
				assertIsSynced(customer, true);
			});
			
			var customer:Customer = _store.create(Customer);
			customer.save(new CommitResponder(function():void
			{
				test.complete();
			}));
			
			assertThat(customer.state.isBusy, equalTo(true));
		}
		
		[Test(async)]
		public function testDestroy():void
		{
			var test:AsyncTest = new AsyncTest(this, LATENCY+(200*2), function():void
			{
				assertIsSynced(customer, false);
			});
			
			var customer:Customer = _store.query(Customer).find(1);
			customer.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				customer.destroy().save(new CommitResponder(function():void
				{
					test.complete();
				}));
				
				assertThat(customer.state.isBusy, equalTo(true));
			});
			customer.load();
		}
		
		[Test(async)]
		public function testUpdate():void
		{
			var test:AsyncTest = new AsyncTest(this, LATENCY+(200*2), function():void
			{
				assertIsSynced(customer, true);
			});
			
			var customer:Customer = _store.query(Customer).find(1);
			customer.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				customer.name = new Name("Steve", "Jobs");
				customer.save(new CommitResponder(function():void
				{
					test.complete();
				}));
				
				assertThat(customer.state.isBusy, equalTo(true));
			});
			customer.load();
		}
	}
}