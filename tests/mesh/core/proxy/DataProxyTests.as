package mesh.core.proxy
{
	import mx.events.PropertyChangeEvent;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	
	public class DataProxyTests
	{
		private var _mock:Mock;
		private var _proxy:DataProxy;
		
		[Before]
		public function setup():void
		{
			_mock = new Mock();
			_proxy = new DataProxy(_mock);
		}
		
		[Test]
		public function testProxyMethodCall():void
		{
			var say:String = "hello world";
			assertThat(_proxy.say(say), equalTo(say));
		}
		
		[Test]
		public function testProxyGetProperty():void
		{
			var name:String = "John Doe";
			_mock.name = name;
			assertThat(_proxy.name, equalTo(name));
		}
		
		[Test]
		public function testProxySetProperty():void
		{
			var name:String = "John Doe";
			_proxy.name = name;
			assertThat(_proxy.name, equalTo(name));
		}
		
		[Test]
		public function testDispatchesPropertyChangeEvents():void
		{
			var e:PropertyChangeEvent;
			
			_proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function(event:PropertyChangeEvent):void
			{
				e = event;
			});
			_proxy.name = "John";
			assertThat(e, notNullValue());
		}
		
		[Test]
		public function testForwardsPropertyChangeEvents():void
		{
			var e:PropertyChangeEvent;
			
			_proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function(event:PropertyChangeEvent):void
			{
				e = event;
			});
			_mock.name = "John";
			assertThat(e, notNullValue());
		}
	}
}

class Mock
{
	[Bindable] public var name:String;
	
	public function say(str:String):String
	{
		return str;
	}
}