package reflection
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.core.IBorder;
	import mx.core.IFlexDisplayObject;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	
	import spark.components.Label;

	public class TypeTests
	{
		[Test]
		public function testClassName():void
		{
			assertThat(new Type(Event).className, equalTo("Event"));
			assertThat(new Type(Number).className, equalTo("Number"));
		}
		
		[Test]
		public function testPackageName():void
		{
			assertThat(new Type(Event).packageName, equalTo("flash.events"));
			assertThat(new Type(Number).packageName, equalTo(""));
		}
		
		[Test]
		public function testName():void
		{
			assertThat(new Type(Event).name, equalTo("flash.events::Event"));
		}
		
		[Test]
		public function testParent():void
		{
			assertThat(new Type(ProgressEvent).parent.className, equalTo("Event"));
		}
		
		[Test]
		public function testParents():void
		{
			assertThat(new Type(ProgressEvent).parents, arrayWithSize(2));
		}
		
		[Test]
		public function testImplementing():void
		{
			assertThat(new Type(Label).implementing, hasItem(allOf(isA(Type), hasProperty("className", equalTo("IUIComponent")))));
			assertThat(new Type(Label).implementing, not(hasItem(hasProperty("className", equalTo("IBorder")))));
		}
		
		[Test]
		public function testIsA():void
		{
			assertThat(new Type(ProgressEvent).isA(ProgressEvent), equalTo(true));
			assertThat(new Type(ProgressEvent).isA(Event), equalTo(true));
			assertThat(new Type(ProgressEvent).isA(new Type(Event)), equalTo(true));
			assertThat(new Type(ProgressEvent).isA(DisplayObject), equalTo(false));
			assertThat(new Type(Label).isA(IFlexDisplayObject), equalTo(true));
			assertThat(new Type(Label).isA(IBorder), equalTo(false));
		}
	}
}