package mesh.core.object
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class CopyTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			var func:Function = function():void {};
			
			var mockWithFunction:MockClass = new MockClass();
			mockWithFunction.function2 = function():void {};
			
			var mock:MockClass = new MockClass();
			mock.value1 = "value1";
			mock.value2 = "value2";
			
			_tests = [
				{to:new MockClass(), from:{value1:"value1", value2:"value2"}, expected:{value1:"value1", value2:"value2"}},
				{to:new MockClass(), from:{value1:"value1", value2:"value2", value10:"value10"}, expected:{value1:"value1", value2:"value2"}},
				{to:mockWithFunction, from:{value1:"value1", value2:"value2", function2:func}, expected:{value1:"value1", value2:"value2", function2:func}},
				{to:new MockClass(), from:{value1:"value1", value2:"value2"}, options:{excludes:["value1"]}, expected:{value1:null, value2:"value2"}},
				{to:{}, from:{value1:"value1", value2:"value2"}, expected:{value1:"value1", value2:"value2"}},
				{to:{}, from:mock, options:{includes:["value1", "value2"]}, expected:{value1:"value1", value2:"value2"}},
				{to:{}, from:mock, options:{includes:["value1", "value2"]}, expected:{value1:"value1", value2:"value2"}},
				{to:{}, from:mock, options:{includes:["value1", "value2"], excludes:["value2"]}, expected:{value1:"value1", value2:null}},
			];
		}
		
		[Test]
		public function testCopy():void
		{
			for each (var test:Object in _tests) {
				copy(test.from, test.to, test.options);
				
				for (var key:String in test.expected) {
					assertThat(test.to[key], equalTo(test.expected[key]));
				}
			}
		}
	}
}

class MockClass
{
	public var value1:String;
	
	private var _value2:String;
	public function get value2():String
	{
		return _value2;
	}
	public function set value2(value:String):void
	{
		_value2 = value;
	}
	
	public function function1():String
	{
		return "hi";
	}
	
	public var function2:Function;
}