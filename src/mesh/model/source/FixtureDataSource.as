package mesh.model.source
{
	import collections.HashMap;
	
	import mesh.core.object.merge;
	import mesh.model.store.Data;
	import mesh.model.store.EntityRequest;

	/**
	 * A data source that is used for static or test data.
	 * 
	 * @author Dan Schultz
	 */
	public class FixtureDataSource extends DataSource
	{
		private var _fixtures:HashMap = new HashMap();
		
		private var _type:Class;
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of entities this data source is for.
		 * @param options A hash of options.
		 */
		public function FixtureDataSource(type:Class, options:Object = null)
		{
			super();
			_type = type;
			_options = merge({idField:"id"}, options);
		}
		
		/**
		 * Adds a fixture to this data source.
		 * 
		 * @param data The data to add.
		 */
		public function add(data:Object):void
		{
			_fixtures.put(data[_options.idField], data);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(request:EntityRequest):void
		{
			if (request.entity.reflect.clazz != _type) {
				throw new ArgumentError("Invalid entity type.");
			}
			request.result( new Data(_fixtures.grab(request.entity.id), _type) );
		}
	}
}