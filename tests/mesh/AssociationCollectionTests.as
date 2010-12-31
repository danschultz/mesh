package mesh
{
	import mesh.associations.AssociationCollection;
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Order;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;

	public class AssociationCollectionTests
	{
		private var _collection:AssociationCollection;
		
		[Before]
		public function setup():void
		{
			_collection = new Customer().ordersAssociation;
			
			var target:Array = [];
			var address:Address = new Address("2306 Zanker Rd", "San Jose");
			var order:Order = new Order();
			order.id = 1;
			order.shippingAddress = address;
			target.push(order);
			
			order = new Order();
			order.id = 2;
			order.shippingAddress = address;
			target.push(order);
			
			order = new Order();
			order.id = 3;
			order.shippingAddress = address;
			target.push(order);
			
			_collection.target = target;
			_collection.loaded();
		}
		
		[Test]
		public function testRevertRestoresToOriginalEntities():void
		{
			var originals:Array = _collection.toArray();
			_collection.removeItemAt(2);
			_collection.removeItemAt(1);
			_collection.addItem(new Order());
			_collection.addItem(new Order());
			_collection.revert();
			assertThat(_collection.toArray(), array(originals[0], originals[1], originals[2]));
		}
		
		[Test]
		public function testRevertAlsoRevertsEntities():void
		{
			var order:Order = _collection.getItemAt(0) as Order;
			order.shippingAddress = new Address("1 Infinite Loop", "Cupertino");
			
			_collection.revert();
			assertThat(order.isDirty, equalTo(false));
		}
		
		[Test]
		public function testAddingDestroyedEntityIsDirty():void
		{
			var order:Order = new Order();
			order.id = 3;
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.callback("afterDestroy");
			
			_collection.addItem(order);
			assertThat(_collection.isDirty, equalTo(true));
		}
		
		[Test]
		public function testFindRemovedEntitiesDoesntContainNonPersistedEntities():void
		{
			var order:Order = new Order();
			_collection.addItem(order);
			
			_collection.removeItem(order);
			assertThat(_collection.findRemovedEntities().toArray(), not(hasItem(order)));
		}
	}
}