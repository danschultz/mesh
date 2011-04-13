package mesh
{
	import mesh.associations.HasManyAssociation;
	import mesh.associations.HasOneAssociation;
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
		public function testHasManyAssociationReturnsHasMany():void
		{
			assertThat(_customer.orders, isA(HasManyAssociation));
		}
		
		[Test]
		public function testHasOneAssociationReturnsHasOne():void
		{
			assertThat(_customer.account, isA(HasOneAssociation));
		}
	}
}