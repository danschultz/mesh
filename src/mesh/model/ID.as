package mesh.model
{
	/**
	 * A class for representing object ID's.
	 * 
	 * @author Dan Schultz
	 */
	public class ID
	{
		/**
		 * Checks if an ID on an object is populated. An ID is populated if the value is not null, and 
		 * one of these cases are met:
		 * 
		 * <ul>
		 * <li>The value is non-zero.</li>
		 * <li>The value is a non-empty string.</li>
		 * </ul>
		 * 
		 * @param obj The object to check.
		 * @param idField The field to check.
		 * @return <code>true</code> if the ID is populated.
		 */
		public static function isPopulated(obj:Object, idField:String = "id"):Boolean
		{
			return obj != null && obj[idField] != null && (obj[idField] != 0 || obj[idField] != "");
		}
	}
}