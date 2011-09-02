package mesh
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	[RemoteClass(alias="mesh.Name")]
	
	public class Name implements IExternalizable
	{
		public function Name(first:String = "", last:String = "")
		{
			_first = first;
			_last = last;
		}
		
		public function equals(name:Name):Boolean
		{
			return first == name.first && last == name.last;
		}
		
		public function readExternal(input:IDataInput):void
		{
			_first = input.readUTF();
			_last = input.readUTF();
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(first);
			output.writeUTF(last);
		}
		
		private var _first:String;
		public function get first():String
		{
			return _first;
		}
		
		private var _last:String;
		public function get last():String
		{
			return _last;
		}
	}
}