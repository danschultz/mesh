package mesh
{
	/**
	 * A relationship represents an association between two entities, where the <code>owner</code>
	 * is the host of the <code>target</code>. Take an example where you have an association
	 * where a Post contains a set of Comments. In this example, Post would be your owner and 
	 * Comment is your target.
	 * 
	 * @author Dan Schultz
	 */
	public class Relationship
	{
		/**
		 * Constructor.
		 * 
		 * @param owner The source of the assocation.
		 * @param property The property or method on the source that references the destination.
		 * @param target The destination of the association.
		 * @param options A set of options defined for this relationship.
		 */
		public function Relationship(owner:Class, property:String, target:Class, options:Object)
		{
			_owner = owner;
			_property = property;
			_target = target;
			_options = options;
		}
		
		/**
		 * Checks that two relationships are equal.
		 * 
		 * @param relationship The relationship to check with.
		 * @return <code>true</code> if the two are equal.
		 */
		public function equals(relationship:Relationship):Boolean
		{
			return relationship != null && 
				   owner == relationship.owner &&
				   property == relationship.property &&
				   target == relationship.target;
		}
		
		/**
		 * @private
		 */
		public function hashCode():Object
		{
			return property;
		}
		
		private var _options:Object;
		/**
		 * A set of options that a client has configured for this relationship.
		 */
		public function get options():Object
		{
			return _options;
		}
		
		private var _owner:Class;
		/**
		 * The source entity for the association.
		 */
		public function get owner():Class
		{
			return _owner;
		}
		
		private var _property:String;
		/**
		 * The property or method on the source that references the destination.
		 */
		public function get property():String
		{
			return _property;
		}
		
		private var _target:Class;
		/**
		 * The destination entity for the association.
		 */
		public function get target():Class
		{
			return _target;
		}
	}
}