package mesh
{
	import mesh.model.store.LocalQuery;
	
	import mx.collections.IList;
	
	[RemoteClass(alias="mesh.Employee")]
	
	public class Employee extends Person
	{
		[Bindable] public var employer:Organization;
		public var employerId:int;
		[Bindable] public var tasks:IList;
		
		public function Employee(properties:Object=null)
		{
			super(properties);
			
			hasOne("employer", {lazy:true, foreignKey:"employerId"});
			hasMany("tasks", {
				lazy:true,
				isMaster:true,
				query:new LocalQuery().on(Task).where(function(task:Task):Boolean
				{
					return equals(task.owner);
				})
			});
		}
	}
}