package mesh.core.serialization
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class SerializerTests
	{
		[Test]
		public function testMarshall():void
		{
			var person:Object = {
				name: "Jimmy Page",
				age: 67
			};
			
			var serialized:Object = new Serializer({includeDynamic:true}).marshal(person, new ObjectSerializerDelegate());
			assertThat(serialized.name, equalTo(person.name));
			assertThat(serialized.age, equalTo(person.age));
		}
		
		[Test]
		public function testMarshallCircularReference():void
		{
			var guitarist:Object = {
				name: "Jimmy Page",
				age: 67
			};
			var guitar:Object = {
				name: "Gibson"
			};
			guitarist.guitar = guitar;
			guitar.owner = guitarist;
			
			var serialized:Object = new Serializer({includeDynamic:true}).marshal(guitarist, new ObjectSerializerDelegate());
			assertThat(serialized.guitar.name, equalTo(guitar.name));
			assertThat(serialized.guitar.owner, equalTo(serialized));
		}
	}
}