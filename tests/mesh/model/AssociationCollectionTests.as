package mesh.model
{
	import flash.utils.flash_proxy;
	
	import mesh.Address;
	import mesh.Customer;
	import mesh.Order;
	import mesh.model.associations.AssociationCollection;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;

	use namespace flash_proxy;
	
	public class AssociationCollectionTests
	{
		private var _collection:AssociationCollection;
		
		[Before]
		public function setup():void
		{
			_collection = new Customer().orders;
			
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
			
			_collection.flash_proxy::object = target;
			_collection.callback("afterLoad");
		}
		
		[Test]
		public function testBuild():void
		{
			var order:Order = _collection.build({total:15});
			assertThat(order.customer.flash_proxy::object, isA(Customer));
			assertThat(order.total, equalTo(15));
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
		public function testDestroyEntityBelongingToAssociation():void
		{
			var order:Order = new Order();
			_collection.add(order);
			_collection.save().execute();
			
			_collection.destroy(order).execute();
			assertThat(order.isDestroyed, equalTo(true));
			assertThat(_collection.contains(order), equalTo(false));
			assertThat(_collection.isDirty, equalTo(false));
		}
		
		[Test]
		public function testDestroyedEntityIsNewWhenReadded():void
		{
			var order:Order = new Order();
			order.id = 3;
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.callback("afterDestroy");
			
			_collection.addItem(order);
			assertThat(order.isNew, equalTo(true));
			assertThat(order.isDirty, equalTo(true));
		}
		
		[Test]
		public function testDestroyingReaddedEntityDoesNotRemoveEntity():void
		{
			var order:Order = new Order();
			order.id = 3;
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.markForRemoval();
			
			_collection.addItem(order);
			order.callback("afterDestroy");
			assertThat(_collection.contains(order), equalTo(true));
		}
		
		[Test]
		public function testReset():void
		{
			var order:Order = _collection.getItemAt(0) as Order;
			
			_collection.reset();
			
			assertThat(order.isMarkedForRemoval, equalTo(false));
			assertThat(_collection.dirtyEntities, emptyArray());
			assertThat(_collection.length, equalTo(0));
			assertThat(_collection.isLoaded, equalTo(false));
		}
		
		[Test]
		public function testDoNotDestroyEntityThatIsRemovedFromSingleAssociation():void
		{
			// Test that when an entity is removed from an association, but belongs to another 
			// association, it will not be destroyed.
			var order:Order = _collection.getItemAt(0) as Order;
			var collection2:AssociationCollection = new Customer().orders;
			
			collection2.add(order);
			_collection.remove(order);
			
			_collection.save().execute();
			assertThat(order.isDestroyed, equalTo(false));
		}
	}
}