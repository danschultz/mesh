package mesh
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mesh.associations.AssociationProxy;
	
	public dynamic class Visitor extends Proxy
	{
		public function Visitor()
		{
			super();
		}
		
		public function enter(association:AssociationProxy):Boolean
		{
			return true;
		}
		
		public function visit(association:AssociationProxy):void
		{
			
		}
		
		public function exit(association:AssociationProxy):Boolean
		{
			return true;
		}
		
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			return visit(parameters[0]);
		}
	}
}