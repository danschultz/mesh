package mesh.model.source
{
	import mesh.Customer;
	import mesh.Organization;
	import mesh.Person;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class MultiSourceTests
	{
		private var _source:MultiSource;
		private var _subSource:MultiSourceTestSource;
		
		[Before]
		public function setup():void
		{
			_subSource = new MultiSourceTestSource();
			_source = new MultiSource();
			_source.map(Person, _subSource);
		}
		
		[Test]
		public function testEntityIsMappedToSource():void
		{
			//_source.retrieveEach(null, [new Person()]);
			assertThat(_subSource.called, equalTo(true));
		}
		
		[Test]
		public function testEntityInheritsMappedSource():void
		{
			//_source.retrieveEach(null, [new Customer()]);
			assertThat(_subSource.called, equalTo(true));
		}
		
		[Test(expects="Error")]
		public function testErrorIfSourceIsUnmapped():void
		{
			//_source.retrieveEach(null, [new Organization()]);
		}
	}
}

import mesh.model.Entity;
import mesh.model.source.Source;
import mesh.model.store.AsyncRequest;

class MultiSourceTestSource extends Source
{
	public var called:Boolean;
	
	override public function retrieve(entity:Entity):void
	{
		called = true;
	}
}