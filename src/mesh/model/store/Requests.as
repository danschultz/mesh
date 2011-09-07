package mesh.model.store
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;

	/**
	 * The <code>Requests</code> class caches requests for a store while the request is loading.
	 * 
	 * @author Dan Schultz
	 */
	public class Requests
	{
		private var _store:Store;
		private var _cache:Dictionary = new Dictionary();
		
		/**
		 * Constructor.
		 * 
		 * @param store The store to cache requests for.
		 */
		public function Requests(store:Store)
		{
			_store = store;
		}
		
		private function cache(key:Object, request:AsyncRequest):void
		{
			if (_cache[key] != null) {
				throw new IllegalOperationError("Request for '" + key + "' has already been cached.");
			}
			
			_cache[key] = request;
			request.responder({
				result:function(data:*):void
				{
					purge(key);
				},
				failed:function(reason:*):void
				{
					purge(key);
				}
			});
		}
		
		private function cached(key:Object):AsyncRequest
		{
			return _cache[key];
		}
		
		private function purge(key:Object):void
		{
			delete _cache[key];
		}
		
		/**
		 * Generates a new request or returns a cached request for the given object.
		 * 
		 * @param queryOrEntity The query or entity to get the request for.
		 * @return A request.
		 */
		public function request(...args):AsyncRequest
		{
			var request:AsyncRequest;
			
			// A single entity is being requested.
			if (args.length == 2 && args[0] is Class) {
				var entity:Entity = findEntity(args[0], args[1]);
				if (cached(entity) != null) {
					request = cached(entity);
				} else {
					request = new EntityRequest(_store, entity, args[2]);
					cache(entity, request);
				}
			}
			
			// A result list is being requested.
			if (args[0] is Query) {
				if (cached(args[0]) != null) {
					request = cached(args[0]);
				} else {
					request = new QueryRequest(_store, args[0], args[1]);
					cache(args[0], request);
				}
			}
			
			return request;
		}
		
		private function findEntity(type:Class, id:Object):Entity
		{
			var entity:Entity = _store.index.findByTypeAndID(type, id);
			
			// The entity doesn't exist in the store yet. Load it.
			if (entity == null) {
				entity = newInstance(type);
				entity.id = id;
			}
			
			return entity;
		}
	}
}