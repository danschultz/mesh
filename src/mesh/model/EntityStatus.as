package mesh.model
{
	import flash.events.EventDispatcher;
	
	import mesh.core.state.Action;
	import mesh.core.state.State;
	import mesh.core.state.StateEvent;
	import mesh.core.state.StateMachine;
	
	/**
	 * Dispatched when the status enters a new state.
	 */
	[Event(name="enter", type="mesh.core.state.StateEvent")]
	
	/**
	 * Dispatched when the status exits an existing state.
	 */
	[Event(name="exit", type="mesh.core.state.StateEvent")]
	
	/**
	 * The <code>EntityStatus</code> class is responsible for tracking the state of the entity
	 * within the application to its remote source. 
	 * 
	 * @author Dan Schultz
	 */
	public class EntityStatus extends EventDispatcher
	{
		private var _state:StateMachine;
		private var _loading:Action;
		private var _destroy:Action;
		private var _dirty:Action;
		private var _synced:Action;
		
		private var _entity:Entity;
		
		/**
		 * Constructor.
		 * 
		 * @param entity The entity to track.
		 */
		public function EntityStatus(entity:Entity)
		{
			super();
			
			_entity = entity;
			
			_state = new StateMachine();
			_state.addEventListener(StateEvent.ENTER, function(event:StateEvent):void
			{
				dispatchEvent(event.clone());
			});
			_state.addEventListener(StateEvent.EXIT, function(event:StateEvent):void
			{
				dispatchEvent(event.clone());
			});
			setupStates(_state);
		}
		
		/**
		 * Puts the entity into a dirty state. The dirty state represents that the application 
		 * has modified an attribute of the entity and needs to be synced.
		 */
		public function dirty():void
		{
			_dirty.trigger();
		}
		
		/**
		 * Puts the entity into a destroyed state. The destroyed state represents the application
		 * has destroyed the entity locally, and needs to be synced.
		 */
		public function destroy():void
		{
			_destroy.trigger();
		}
		
		private function isInState(state:String):Boolean
		{
			return _state.current.name.search(state) != -1;
		}
		
		/**
		 * Puts the entity into a loading state. The loading state represents that the application
		 * is busy loading data for the entity from the remote source.
		 */
		public function loading():void
		{
			_loading.trigger();
		}
		
		/**
		 * Puts the entity into a synced state. The synced state represents that the application and
		 * the remote source are the same.
		 */
		public function synced():void
		{
			_synced.trigger();
		}
		
		private function setupStates(machine:StateMachine):void
		{
			var newDirtyState:State = _state.createState("new dirty");
			
			var loadingBusyState:State = _state.createState("loading busy");
			
			var persistedState:State = _state.createState("persisted").onEnter(_entity.changes.clear);
			var persistedDirtyState:State = _state.createState("persisted dirty");
			
			var destroyedState:State = _state.createState("destroyed");
			var destroyedDirtyState:State = _state.createState("destroyed dirty");
			
			_loading = _state.createAction("loading").transitionTo(loadingBusyState, newDirtyState);
			_dirty = _state.createAction("dirty").transitionTo(persistedDirtyState, persistedState);
			
			_destroy = _state.createAction("destroy").transitionTo(destroyedDirtyState, [persistedState, persistedDirtyState]);
			
			_synced = _state.createAction("synced");
			_synced.transitionTo(persistedState, [loadingBusyState, newDirtyState, persistedDirtyState]);
			_synced.transitionTo(destroyedState, destroyedDirtyState);
		}
		
		public function get isBusy():Boolean
		{
			return isInState("busy");
		}
		
		public function get isDirty():Boolean
		{
			return isInState("dirty");
		}
		
		public function get isDestroyed():Boolean
		{
			return isInState("destroy");
		}
		
		private function get isLocked():Boolean
		{
			return isInState("locked");
		}
		
		public function get isNew():Boolean
		{
			return isInState("new");
		}
		
		public function get isPersisted():Boolean
		{
			return isInState("persisted");
		}
		
		public function get isSynced():Boolean
		{
			return !isDirty && !isBusy;
		}
		
		[Bindable(event="enter")]
		public function get state():State
		{
			return _state.current;
		}
	}
}