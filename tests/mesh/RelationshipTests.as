package mesh
{
	import mesh.associations.HasManyRelationship;
	import mesh.associations.HasOneRelationship;
	import mesh.models.Aircraft;
	import mesh.models.Airplane;
	import mesh.models.Customer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	import org.hamcrest.object.instanceOf;

	public class RelationshipTests
	{
		[Test]
		public function testRelationshipMetadata():void
		{
			var relationships:Array = new Customer().descriptor.relationships.toArray();
			assertThat(relationships, hasItem(allOf(instanceOf(HasManyRelationship), hasProperty("property", equalTo("orders")))));
		}
		
		[Test]
		public function testRelationshipMetadataSetsPropertyAsPluralizedType():void
		{
			var relationships:Array = new Customer().descriptor.relationships.toArray();
			assertThat(relationships, hasItem(allOf(instanceOf(HasManyRelationship), hasProperty("property", equalTo("cars")))));
		}
		
		[Test]
		public function testRelationshipMetadataOnGetterSetsPropertyAsGetter():void
		{
			var relationships:Array = new Customer().descriptor.relationships.toArray();
			assertThat(relationships, hasItem(allOf(instanceOf(HasOneRelationship), hasProperty("property", equalTo("primaryCar")))));
		}
		
		[Test]
		public function testRelationshipMetadataDoesNotHaveDuplicatesFromSuperClass():void
		{
			var airplane:Aircraft = new Airplane();
			var relationships:Array = airplane.descriptor.relationships.toArray();
			assertThat(relationships, arrayWithSize(1));
		}
	}
}