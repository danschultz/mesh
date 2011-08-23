package mesh.core.reflection
{
	import flash.display.DisplayObject;
	import flash.display.Shader;
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
		
		[Test]
		public function testConstantReadWriteAttributes():void
		{
			var property:Property = new Type(Event).property("ACTIVATE");
			assertThat(property.isReadable, equalTo(true));
			assertThat(property.isWritable, equalTo(false));
		}
		
		[Test]
		public function testVariableReadWriteAttributes():void
		{
			var property:Property = new Type(Point).property("x");
			assertThat(property.isReadable, equalTo(true));
			assertThat(property.isWritable, equalTo(true));
		}
		
		[Test]
		public function testGetterSetterReadWriteAttributes():void
		{
			var property:Property = new Type(DisplayObject).property("alpha");
			assertThat(property.isReadable, equalTo(true));
			assertThat(property.isWritable, equalTo(true));
		}
		
		[Test]
		public function testGetterReadWriteAttributes():void
		{
			var property:Property = new Type(Point).property("length");
			assertThat(property.isReadable, equalTo(true));
			assertThat(property.isWritable, equalTo(false));
		}
		
		[Test]
		public function testSetterReadWriteAttributes():void
		{
			var property:Property = new Type(Shader).property("byteCode");
			assertThat(property.isReadable, equalTo(false));
			assertThat(property.isWritable, equalTo(true));
		}
		
		[Test]
		public function testValueForInstanceProperty():void
		{
			var property:Property = new Type(Point).property("x");
			var point:Point = new Point(10, 1);
			assertThat(property.value(point), equalTo(point.x));
		}
		
		[Test]
		public function testValueForClassProperty():void
		{
			var property:Property = new Type(Event).property("ACTIVATE");
			var event:Event = new Event("");
			assertThat(property.value(Event), equalTo(Event.ACTIVATE));
			assertThat(property.value(event), equalTo(Event.ACTIVATE));
		}
	}
}