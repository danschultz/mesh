package mesh
{
	import mesh.model.Entity;
	import mesh.model.store.RemoteQuery;
	
	import mx.collections.IList;
	
	public class Organization extends Entity
	{
		[Bindable] public var name:String;
		[Bindable] public var employees:IList;
		
		public function Organization(values:Object=null)
		{
			super(values);
			
			hasMany("employees", {
				lazy:true,
				isMaster:true,
				inverse:"employer",
				query:new RemoteQuery().on(Employee).where(function(employee:Employee):Boolean
				{
					return id == employee.employerId;
				})
			});
		}
	}
}