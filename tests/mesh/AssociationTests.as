package mesh
{
	import mesh.models.Customer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.core.isA;

	public class AssociationTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
		}
		
		[Test]
		public function testHasManyRelationshipReturnsAssociationCollectionProxy():void
		{
			assertThat(_customer.orders, isA(AssociationCollection));
		}
		
		[Test]
		public function testHasOneRelationshipReturnsHasOneAssociationProxy():void
		{
			
		}
	}
}