package reflection
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;

	public class PropertiesTests
	{
		[Test]
		public function testPropertiesContainsClassVariables():void
		{
			assertThat(new Type(Event).properties, hasItem(allOf(hasProperty("name", equalTo("ACTIVATE")), hasProperty("isStatic", equalTo(true)))));
		}
		
		[Test]
		public function testPropertiesContainsInstanceVariables():void
		{
			assertThat(new Type(Point).properties, hasItem(allOf(hasProperty("name", equalTo("x")), hasProperty("isStatic", equalTo(false)))));
		}
		
		[Test]
		public function testPropertiesContainsGettersAndSetters():void
		{
			assertThat(new Type(Event).properties, hasItem(allOf(hasProperty("name", equalTo("type")), hasProperty("isStatic", equalTo(false)))));
		}
		
		[Test]
		public function testPropertiesContainsPropertiesFromParent():void
		{
			assertThat(new Type(ProgressEvent).properties, hasItem(allOf(hasProperty("name", equalTo("type")), hasProperty("isStatic", equalTo(false)))));
		}
		
		[Test]
		public function testPropertiesDoesNotContainStaticPropertiesFromParent():void
		{
			assertThat(new Type(ProgressEvent).properties, not(hasItem(allOf(hasProperty("name", equalTo("ACTIVATE")), hasProperty("isStatic", equalTo(true))))));
		}
	}
}