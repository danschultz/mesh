package reflection
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;

	public class PropertiesTests
	{
		[Test]
		public function testPropertiesContainsClassVariables():void
		{
			var property:Property = new Type(Event).property("ACTIVATE");
			assertThat(property, notNullValue());
			assertThat(property.isStatic, equalTo(true));
		}
		
		[Test]
		public function testPropertiesContainsInstanceVariables():void
		{
			var property:Property = new Type(Point).property("x");
			assertThat(property, notNullValue());
			assertThat(property.isStatic, equalTo(false));
		}
		
		[Test]
		public function testPropertiesContainsGettersAndSetters():void
		{
			var property:Property = new Type(Event).property("type");
			assertThat(property, notNullValue());
			assertThat(property.isStatic, equalTo(false));
		}
		
		[Test]
		public function testPropertiesContainsPropertiesFromParent():void
		{
			var property:Property = new Type(ProgressEvent).property("type");
			assertThat(property, notNullValue());
			assertThat(property.isStatic, equalTo(false));
		}
		
		[Test]
		public function testPropertiesDoesNotContainStaticPropertiesFromParent():void
		{
			var property:Property = new Type(ProgressEvent).property("ACTIVATE");
			assertThat(property, nullValue());
		}
		
		[Test]
		public function testPropertyType():void
		{
			assertThat(new Type(Point).property("x").type.clazz, equalTo(Number));
			assertThat(new Type(ProgressEvent).property("cancelable").type.clazz, equalTo(Boolean));
		}
	}
}