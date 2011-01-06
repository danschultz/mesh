package mesh
{
	import mesh.associations.HasManyRelationship;
	import mesh.associations.HasOneRelationship;
	import mesh.models.Aircraft;
	import mesh.models.Airplane;
	import mesh.models.Customer;
	import mesh.models.Order;
	import mesh.models.Person;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.everyItem;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.collection.hasItems;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
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
			assertThat(relationships, hasItem(allOf(instanceOf(HasOneRelationship), hasProperty("property", equalTo("account")))));
		}
		
		[Test]
		public function testRelationshipMetadataUsesSuperClass():void
		{
			var airplane:Aircraft = new Airplane();
			var relationships:Array = airplane.descriptor.relationships.toArray();
			assertThat(relationships, hasItem(allOf(hasProperty("property", equalTo("manufacturers")), hasProperty("owner", equalTo(Aircraft)))));
			assertThat(relationships, not(hasItem(allOf(hasProperty("property", equalTo("manufacturers")), hasProperty("owner", equalTo(Airplane))))));
		}
		
		[Test]
		public function testEntityContainsRelationshipProperties():void
		{
			var tests:Array = [{instance:new Customer(), expects:["orders", "cars", "account"]},
							   {instance:new Airplane(), expects:["manufacturers"]},
							   {instance:new Order(), expects:["customer", "customerId"]},
							   {instance:new Person(), expects:["partner", "partnerId"]}];
			
			for each (var test:Object in tests) {
				var properties:Array = test.instance.properties.toArray();
				assertThat("test failed for " + test.expects, properties, everyItem(isA(String)));
				assertThat("test failed for " + test.expects, properties, hasItems.apply(null, test.expects));
			}
		}
	}
}