package mesh
{
	import mesh.model.Entity;
	
	[RemoteClass(alias="mesh.Task")]
	
	public class Task extends Entity
	{
		[Bindable] public var owner:Employee;
		public var ownerId:int;
		
		public function Task(values:Object=null)
		{
			super(values);
			hasOne("owner", {lazy:true, foreignKey:"ownerId"});
		}
	}
}