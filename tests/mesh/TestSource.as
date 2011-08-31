package mesh
{
	import mesh.model.source.FixtureSource;
	import mesh.model.source.MultiSource;
	
	public class TestSource extends MultiSource
	{
		public function TestSource()
		{
			super();
			
			map(Customer, new FixtureSource(Customer));
			map(Account, new FixtureSource(Account));
			map(Person, new FixtureSource(Person));
			map(Order, new FixtureSource(Order));
			
			map(Organization, new FixtureSource(Organization));
			map(Employee, new FixtureSource(Employee));
			map(Task, new FixtureSource(Task));
		}
	}
}