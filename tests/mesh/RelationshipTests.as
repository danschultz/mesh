package mesh
{
	import mesh.models.Customer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	import org.hamcrest.object.instanceOf;
	import mesh.associations.HasManyRelationship;
	import mesh.associations.HasOneRelationship;

	public class RelationshipTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
		}
		
		[Test]
		public function testRelationshipMetadata():void
		{
			var relationships:Array = _customer.associations;
			assertThat(relationships, hasItem(allOf(instanceOf(HasManyRelationship), hasProperty("property", equalTo("orders")))));
		}
		
		[Test]
		public function testRelationshipMetadataSetsPropertyAsPluralizedType():void
		{
			var relationships:Array = _customer.associations;
			assertThat(relationships, hasItem(allOf(instanceOf(HasManyRelationship), hasProperty("property", equalTo("cars")))));
		}
		
		[Test]
		public function testRelationshipMetadataOnGetterSetsPropertyAsGetter():void
		{
			var relationships:Array = _customer.associations;
			assertThat(relationships, hasItem(allOf(instanceOf(HasOneRelationship), hasProperty("property", equalTo("primaryCar")))));
		}
	}
}