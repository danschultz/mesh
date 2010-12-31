package mesh
{
	import mesh.associations.AssociationCollection;
	import mesh.models.Customer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;

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
			assertThat(_customer.ordersAssociation, isA(AssociationCollection));
		}
		
		[Test]
		public function testHasOneRelationshipReturnsHasOneAssociationProxy():void
		{
			
		}
	}
}