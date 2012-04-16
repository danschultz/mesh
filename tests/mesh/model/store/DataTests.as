package mesh.model.store
{
	import mesh.Person;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class DataTests
	{
		public static var READ_DATA:Array = [
			[{name:"Jimmy Page"}, "name"]
		];
		
		public static var SET_DATA:Array = [
			[{}, "name", "Jimmy Page"]
		];
		
		[Test]
		public function testIdFieldOption():void
		{
			var ID:int = 1;
			var data:Data = new Data(Person, {personId:ID}, {idField:"personId"});
			assertThat(data.id, equalTo(ID));
		}
		
		[Test(dataProvider="READ_DATA")]
		public function testReadProperty(obj:Object, property:String):void
		{
			var data:Data = new Data(Person, obj);
			assertThat(data[property], notNullValue());
		}
		
		[Test(dataProvider="SET_DATA")]
		public function testSetProperty(obj:Object, property:String, value:Object):void
		{
			var data:Data = new Data(Person, obj);
			data[property] = value;
			assertThat(data[property], equalTo(value));
		}
	}
}