package mesh.model
{
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	
	import org.flexunit.assertThat;
	import org.hamcrest.core.isA;
	import mesh.Customer;

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