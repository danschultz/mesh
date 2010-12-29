package reflection
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;
	
	import spark.components.Label;

	public class MethodTests
	{
		[Test]
		public function testMethodsContainsClassMethods():void
		{
			var method:Method = new Type(Point).method("interpolate");
			assertThat(method, notNullValue());
			assertThat(method.isStatic, equalTo(true));
		}
		
		[Test]
		public function testMethodsContainsInstanceMethods():void
		{
			var method:Method = new Type(Point).method("add");
			assertThat(method, notNullValue());
			assertThat(method.isStatic, equalTo(false));
		}
		
		[Test]
		public function testMethodsContainsMethodsFromParent():void
		{
			var method:Method = new Type(ProgressEvent).method("formatToString");
			assertThat(method, notNullValue());
			assertThat(method.isStatic, equalTo(false));
		}
		
		[Test]
		public function testMethodsDoesNotContainPropertiesFromParent():void
		{
			var method:Method = new Type(Label).method("suspendBackgroundProcessing");
			assertThat(method, nullValue());
		}
		
		[Test]
		public function testMethodReturnType():void
		{
			assertThat(new Type(ProgressEvent).method("preventDefault").returnType, nullValue());
			assertThat(new Type(ProgressEvent).method("clone").returnType.clazz, equalTo(Event));
		}
	}
}