package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.Type;
	import mesh.model.Entity;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>object</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public class Association extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param owner The parent that owns the relationship.
		 * @param options The options for this association.
		 */
		public function Association(owner:Entity, options:Object = null)
		{
			super();
			_owner = owner;
			_options = options != null ? options : {};
		}
		
		/**
		 * Called by sub-classes when an entity is added to an association.
		 * 
		 * @param entity The entity that was associated.
		 */
		protected function associate(entity:Entity):void
		{
			owner.store.add(entity);
			populateInverseRelationship(entity);
		}
		
		/**
		 * Executes the query to load the data for this association. Sub-classes from <code>Association</code>
		 * are required to override and implement this method.
		 */
		public function load():void
		{
			throw new IllegalOperationError(reflect.name + ".load() is not implemented.");
		}
		
		/**
		 * Called by sub-classes when the loading of the association's data has started.
		 */
		protected function loading():void
		{
			if (!_isLoading) {
				_isLoading = true;
				dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, "isLoading", false, true) );
			}
		}
		
		/**
		 * Called by sub-classes when the loading of the association's data has finished.
		 * 
		 * @param result The <code>Entity</code> or <code>ResultList</code> that was loaded.
		 */
		protected function loaded(result:Object):void
		{
			if (!_isLoaded) {
				_isLoaded = true;
				_isLoading = false;
				dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, "isLoading", true, false) );
				dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, "isLoaded", false, true) );
			}
		}
		
		private function populateInverseRelationship(entity:Entity):void
		{
			if (inverse != null) {
				if (entity.hasOwnProperty(inverse)) entity[inverse] = owner;
				else throw new IllegalOperationError("Inverse property '" + entity.reflect.name + "." + inverse + "' does not exist.");
			}
		}
		
		/**
		 * Changes the state of the object for this association back to what it was at the last save.
		 */
		public function revert():void
		{
			
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return humanize(reflect.className).toLowerCase();
		}
		
		/**
		 * Called by a sub-class when an entity has been removed from an association.
		 * 
		 * @param entity The entity to unassociate.
		 */
		protected function unassociate(entity:Entity):void
		{
			
		}
		
		/**
		 * The property on each associated object that maps back to the owner of the association.
		 */
		protected function get inverse():String
		{
			return options.inverse;
		}
		
		private var _isLoaded:Boolean;
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if the association objects for this relationship have been loaded.
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		private var _isLoading:Boolean;
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if this association is in the process of loading its data.
		 */
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		
		private var _object:*;
		/**
		 * The data assigned to this association.
		 */
		public function get object():*
		{
			return _object;
		}
		public function set object(value:*):void
		{
			_object = value;
		}
		
		private var _options:Object;
		/**
		 * The options defined for this association.
		 */
		protected function get options():Object
		{
			return _options;
		}
		
		private var _owner:Entity;
		/**
		 * The instance of the parent owning this association.
		 */
		protected function get owner():Entity
		{
			return _owner;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection on this object.
		 */
		public function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
	}
}