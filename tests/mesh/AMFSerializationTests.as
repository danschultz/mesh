package mesh
{
	import flash.utils.ByteArray;
	
	import mesh.models.Airplane;
	import mesh.models.Manufacturer;
	import mesh.models.Order;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	public class AMFSerializationTests
	{
		[Test]
		public function testAMFSerialization():void
		{
			var airplane:Airplane = new Airplane();
			var manufacturer:Manufacturer = new Manufacturer();
			manufacturer.name = "Boeing";
			airplane.manufacturers.addItem(manufacturer);
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(airplane);
			
			bytes.position = 0;
			var deserialized:Airplane = bytes.readObject() as Airplane;
			assertThat(airplane.manufacturers.length, equalTo(1));
		}
		
		[Test]
		public function testAMFSerializationWithDynamicEntity():void
		{
			var order:Order = new Order();
			order.shippingAddressStreet = "2306 Zanker Rd";
			order.shippingAddressCity = "San Jose";
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(order);
			
			bytes.position = 0;
			var deserialized:Order = bytes.readObject();
			assertThat(deserialized.shippingAddressStreet, equalTo(order.shippingAddressStreet));
		}
	}
}