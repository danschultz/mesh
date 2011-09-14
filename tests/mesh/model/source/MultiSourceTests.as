package mesh.model.source
{
	import mesh.Customer;
	import mesh.Organization;
	import mesh.Person;
	import mesh.model.store.Commit;
	
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
			_source.createEach(null, [new Person()]);
			assertThat(_subSource.called, equalTo(true));
		}
		
		[Test]
		public function testEntityInheritsMappedSource():void
		{
			_source.createEach(null, [new Customer()]);
			assertThat(_subSource.called, equalTo(true));
		}
		
		[Test(expects="Error")]
		public function testErrorIfSourceIsUnmapped():void
		{
			_source.createEach(null, [new Organization()]);
		}
	}
}

import mesh.model.Entity;
import mesh.model.source.Source;
import mesh.model.store.Commit;

class MultiSourceTestSource extends Source
{
	public var called:Boolean;
	
	override public function create(commit:Commit, entity:Entity):void
	{
		called = true;
	}
}