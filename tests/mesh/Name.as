package mesh
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	[RemoteClass(alias="mesh.Name")]
	
	public class Name implements IExternalizable
	{
		public function Name(firstName:String = "", lastName:String = "")
		{
			_firstName = firstName;
			_lastName = lastName;
		}
		
		public function equals(name:Name):Boolean
		{
			return firstName == name.firstName && lastName == name.lastName;
		}
		
		public function readExternal(input:IDataInput):void
		{
			_firstName = input.readUTF();
			_lastName = input.readUTF();
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(firstName);
			output.writeUTF(lastName);
		}
		
		private var _firstName:String;
		public function get firstName():String
		{
			return _firstName;
		}
		
		private var _lastName:String;
		public function get lastName():String
		{
			return _lastName;
		}
	}
}