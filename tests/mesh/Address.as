package mesh
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	[RemoteClass(alias="mesh.Address")]
	
	public class Address implements IExternalizable
	{
		public function Address(street:String = "", city:String = "")
		{
			_street = street;
			_city = city;
		}
		
		public function equals(address:Address):Boolean
		{
			return street == address.street &&
				city == address.city;
		}
		
		public function readExternal(input:IDataInput):void
		{
			_street = input.readUTF();
			_city = input.readUTF();
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(street);
			output.writeUTF(city);
		}
		
		private var _street:String;
		public function get street():String
		{
			return _street;
		}
		
		private var _city:String;
		public function get city():String
		{
			return _city;
		}
	}
}