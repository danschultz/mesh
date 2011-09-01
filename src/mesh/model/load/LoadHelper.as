package mesh.model.load
{
	import flash.events.IEventDispatcher;
	
	import mesh.core.state.Action;
	import mesh.core.state.State;
	import mesh.core.state.StateMachine;
	import mesh.model.source.SourceFault;
	
	/**
	 * Dispatched when the host starts the loading of its content.
	 */
	[Event(name="loading", type="mesh.model.load.LoadEvent")]
	
	/**
	 * Dispatched when the host has successfully loaded its content.
	 */
	[Event(name="success", type="mesh.model.load.LoadSuccessEvent")]
	
	/**
	 * Dispatched when the host has failed to load its content.
	 */
	[Event(name="failed", type="mesh.model.load.LoadFailedEvent")]
	
	/**
	 * The <code>LoadHelper</code> class assists in managing the necessary states and events required
	 * for an object that loads its data from a remote source.
	 * 
	 * @author Dan Schultz
	 */
	public class LoadHelper
	{
		private var _dispatcher:IEventDispatcher;
		
		private var _state:StateMachine;
		
		private var _initializedState:State;
		private var _loadingState:State;
		private var _failedState:State;
		private var _loadedState:State;
		
		private var _loading:Action;
		private var _loaded:Action;
		private var _failed:Action;
		
		private var _fault:SourceFault;
		
		/**
		 * Constructor.
		 * 
		 * @param host The object that will load its content.
		 */
		public function LoadHelper(host:IEventDispatcher)
		{
			_dispatcher = host;
			
			_state = new StateMachine();
			setupStates(_state);
		}
		
		/**
		 * Called by the host when its content has failed to load.
		 * 
		 * @param fault The reason of the failure.
		 */
		public function failed(fault:SourceFault):void
		{
			_fault = fault;
			_failed.trigger();
		}
		
		/**
		 * Called by the host when it starts to load its content.
		 */
		public function load():void
		{
			_loading.trigger();
		}
		
		/**
		 * Called by the host when it has successfully loaded its content.
		 * 
		 * @param data The loaded data.
		 */
		public function loaded(data:*):void
		{
			_loaded.trigger();
		}
		
		private function setupStates(states:StateMachine):void
		{
			_initializedState = states.createState("initialized");
			_loadedState = states.createState("loaded").onEnter(function():void
			{
				_dispatcher.dispatchEvent( new LoadSuccessEvent(LoadSuccessEvent.SUCCESS) );
			});
			_loadingState = states.createState("loading").onEnter(function():void
			{
				_fault = null;
				_dispatcher.dispatchEvent( new LoadEvent(LoadEvent.LOADING) );
			});
			_failedState = states.createState("failed").onEnter(function():void
			{
				_dispatcher.dispatchEvent( new LoadFailedEvent(LoadFailedEvent.FAILED, _fault) );
			});
			
			_loading = states.createAction("loading").transitionTo(_loadingState, _initializedState);
			_loaded = states.createAction("loaded").transitionTo(_loadedState, _loadingState);
			_failed = states.createAction("failed").transitionTo(_failedState, _loadingState);
		}
		
		public function get hasFailed():Boolean
		{
			return _state.current.name == "failed";
		}
		
		public function get isLoading():Boolean
		{
			return _state.current.name == "loading";
		}
		
		public function get isLoaded():Boolean
		{
			return _state.current.name == "loaded";
		}
	}
}