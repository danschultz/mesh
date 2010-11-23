package mesh
{
	/**
	 * A relationship represents an association between two entities, where the <code>source</code>
	 * is the host of the <code>destination</code>. Take an example where you have an association
	 * where a Post contains a set of Comments. In this example, Post would be your source and 
	 * Comment is your destination.
	 * 
	 * @author Dan Schultz
	 */
	public class Relationship
	{
		/**
		 * A deletion rule, where when the host is removed the destination is kept.
		 */
		public static const NOTHING:String = "nothing";
		
		/**
		 * A deletion rule, where when the host is removed the destination is also removed.
		 */
		public static const CASCADE:String = "cascade";
		
		/**
		 * Constructor.
		 * 
		 * @param source The source of the assocation.
		 * @param property The property or method on the source that references the destination.
		 * @param destination The destination of the association.
		 * @param deletionRule How the destination should be handled when the source is removed.
		 */
		public function Relationship(source:Class, property:String, destination:Class, deletionRule:String)
		{
			_source = source;
			_property = property;
			_destination = destination;
			_deletionRule = deletionRule;
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
				   source == relationship.source &&
				   property == relationship.property &&
				   destination == relationship.destination &&
				   deletionRule == relationship.deletionRule;
		}
		
		/**
		 * @private
		 */
		public function hashCode():Object
		{
			return property;
		}
		
		private var _deletionRule:String;
		/**
		 * How the destination should be handled when the source is removed.
		 */
		public function get deletionRule():String
		{
			return _deletionRule;
		}
		
		private var _destination:Class;
		/**
		 * The destination entity for the association.
		 */
		public function get destination():Class
		{
			return _destination;
		}
		
		private var _property:String;
		/**
		 * The property or method on the source that references the destination.
		 */
		public function get property():String
		{
			return _property;
		}
		
		private var _source:Class;
		/**
		 * The source entity for the association.
		 */
		public function get source():Class
		{
			return _source;
		}
	}
}