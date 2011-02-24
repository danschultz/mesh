package mesh.core.range
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;

	public class RangeTests
	{
		[Test]
		public function testContains():void
		{
			var tests:Array = [
				// integers
				{range:Range.from(1).to(5), value:1, expected:true},
				{range:Range.from(1).to(5), value:5, expected:true},
				{range:Range.from(1).to(5), value:2.5, expected:true},
				{range:Range.from(1).to(5), value:-1, expected:false},
				{range:Range.from(1).to(5), value:6, expected:false},
				{range:Range.from(1).toButNotIncluding(5), value:5, expected:false},
				{range:Range.from(5).to(1), value:1, expected:true},
				{range:Range.from(5).to(1), value:5, expected:true},
				{range:Range.from(5).to(1), value:6, expected:false},
				{range:Range.from(5).toButNotIncluding(1), value:1, expected:false},
				
				// chars
				{range:Range.from("a").to("z"), value:"a", expected:true},
				{range:Range.from("a").to("z"), value:"z", expected:true},
				{range:Range.from("a").toButNotIncluding("z"), value:"z", expected:false},
				{range:Range.from("a").to("z"), value:"Z", expected:false},
				{range:Range.from("A").to("Z"), value:"a", expected:false},
				{range:Range.from("z").to("a"), value:"z", expected:true},
				{range:Range.from("z").to("a"), value:"a", expected:true},
				{range:Range.from("z").to("a"), value:"A", expected:false},
				{range:Range.from("z").toButNotIncluding("a"), value:"a", expected:false},
				
				// dates
				{range:Range.from( new Date(2011, 0, 1) ).to( new Date(2011, 0, 10) ), value:new Date(2011, 0, 1), expected:true},
				{range:Range.from( new Date(2011, 0, 1) ).to( new Date(2011, 0, 10) ), value:new Date(2011, 0, 10), expected:true},
				{range:Range.from( new Date(2011, 0, 1) ).to( new Date(2011, 0, 10) ), value:new Date(2011, 0, 11), expected:false},
				{range:Range.from( new Date(2011, 0, 1) ).to( new Date(2011, 0, 10) ), value:new Date(2010, 11, 31), expected:false},
				{range:Range.from( new Date(2011, 0, 1) ).toButNotIncluding( new Date(2011, 0, 10) ), value:new Date(2010, 0, 10), expected:false}
			];
			
			for each (var test:Object in tests) {
				var range:Range = test.range;
				assertThat("Test failed for range " + test.range + " with value " + test.value, range.contains(test.value), equalTo(test.expected));
			}
		}
		
		[Test]
		public function testStep():void
		{
			var tests:Array = [
				// integers
				{range:Range.from(1).to(5), size:1, expected:"1,2,3,4,5"},
				{range:Range.from(1).to(5), size:2, expected:"1,3,5"},
				{range:Range.from(1).to(5), size:3, expected:"1,4"},
				{range:Range.from(5).to(1), size:1, expected:"5,4,3,2,1"},
				{range:Range.from(5).to(1), size:2, expected:"5,3,1"},
				
				// chars
				{range:Range.from("a").to("e"), size:1, expected:"a,b,c,d,e".split(",")},
				{range:Range.from("a").to("e"), size:2, expected:"a,c,e".split(",")},
				{range:Range.from("e").to("a"), size:1, expected:"e,d,c,b,a".split(",")},
				{range:Range.from("e").to("a"), size:2, expected:"e,c,a".split(",")},
				
				// dates
				{range:Range.from( new Date(2011, 0, 1) ).to( new Date(2011, 0, 5) ), size:1, expected:[new Date(2011, 0, 1), new Date(2011, 0, 2), new Date(2011, 0, 3), new Date(2011, 0, 4), new Date(2011, 0, 5)].join(",")},
				{range:Range.from( new Date(2011, 0, 1) ).to( new Date(2011, 0, 5) ), size:2, expected:[new Date(2011, 0, 1), new Date(2011, 0, 3), new Date(2011, 0, 5)].join(",")},
				{range:Range.from( new Date(2011, 0, 5) ).to( new Date(2011, 0, 1) ), size:1, expected:[new Date(2011, 0, 5), new Date(2011, 0, 4), new Date(2011, 0, 3), new Date(2011, 0, 2), new Date(2011, 0, 1)].join(",")},
				{range:Range.from( new Date(2011, 0, 5) ).to( new Date(2011, 0, 1) ), size:2, expected:[new Date(2011, 0, 5), new Date(2011, 0, 3), new Date(2011, 0, 1)].join(",")},
			];
			
			for each (var test:Object in tests) {
				var range:Range = test.range;
				
				var values:Array = [];
				range.step(test.size, function(item:Object):void
				{
					values.push(item);
				});
				assertThat("Test failed for range " + test.range + " with step size " + test.size, values.join(","), equalTo(test.expected));
			}
		}
		
		[Test]
		public function testIterate():void
		{
			var tests:Array = [
				{range:Range.from(1).to(5), expected:[1, 2, 3, 4, 5]},
				{range:Range.from(5).to(1), step:1, expected:[5, 4, 3, 2, 1]}
			];
			
			for each (var test:Object in tests) {
				var range:Range = test.range;
				
				var values:Array = [];
				for each (var value:int in range) {
					values.push(value);
				}
				assertThat("Test failed for range " + test.range, values, array.apply(null, test.expected));
			}
		}
		
		[Test]
		public function testLength():void
		{
			var tests:Array = [
				{range:Range.from(1).to(5), expected:5},
				{range:Range.from(1).toButNotIncluding(5), expected:4},
				{range:Range.from(5).to(1), expected:5},
				{range:Range.from(5).toButNotIncluding(1), expected:4}
			];
			
			for each (var test:Object in tests) {
				var range:Range = test.range;
				assertThat("Test failed for range " + test.range, range.length, equalTo(test.expected));
			}
		}
		
		[Test]
		public function testMin():void
		{
			var tests:Array = [
				{range:Range.from(1).to(5), expected:1},
				{range:Range.from(5).to(1), expected:1}
			];
			
			for each (var test:Object in tests) {
				var range:Range = test.range;
				assertThat("Test failed for range " + test.range, range.min, equalTo(test.expected));
			}
		}
		
		[Test]
		public function testMax():void
		{
			var tests:Array = [
				{range:Range.from(1).to(5), expected:5},
				{range:Range.from(5).to(1), expected:5}
			];
			
			for each (var test:Object in tests) {
				var range:Range = test.range;
				assertThat("Test failed for range " + test.range, range.max, equalTo(test.expected));
			}
		}
	}
}