package reflection
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	
	import spark.components.Label;

	public class MethodTests
	{
		[Test]
		public function testMethodsContainsClassMethods():void
		{
			assertThat(new Type(Point).methods, hasItem(allOf(hasProperty("name", equalTo("interpolate")), hasProperty("isStatic", equalTo(true)))));
		}
		
		[Test]
		public function testMethodsContainsInstanceMethods():void
		{
			assertThat(new Type(Point).methods, hasItem(allOf(hasProperty("name", equalTo("add")), hasProperty("isStatic", equalTo(false)))));
		}
		
		[Test]
		public function testMethodsContainsMethodsFromParent():void
		{
			assertThat(new Type(Event).methods, hasItem(allOf(hasProperty("name", equalTo("formatToString")), hasProperty("isStatic", equalTo(false)))));
		}
		
		[Test]
		public function testMethodsDoesNotContainPropertiesFromParent():void
		{
			assertThat(new Type(Label).methods, not(hasItem(allOf(hasProperty("name", equalTo("suspendBackgroundProcessing"))))));
		}
	}
}