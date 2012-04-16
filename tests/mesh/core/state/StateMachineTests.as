package mesh.core.state
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class StateMachineTests
	{
		private var _machine:StateMachine;
		private var _state1:State;
		private var _state2:State;
		private var _state3:State;
		private var _changeState:Action;
		
		[Before]
		public function setup():void
		{
			_machine = new StateMachine();
			_state1 = _machine.createState("state1");
			_state2 = _machine.createState("state2");
			_state3 = _machine.createState("state3");
			_changeState = _machine.createAction("changeState");
		}
		
		[Test]
		public function testOnEnter():void
		{
			
			var entered:Boolean;
			_state2.onEnter(function():void
			{
				entered = true;
			});
			
			_changeState.transitionTo(_state2, _state1).trigger();
			assertThat(entered, equalTo(true));
		}
		
		[Test]
		public function testOnExit():void
		{
			var exited:Boolean;
			_state1.onExit(function():void
			{
				exited = true;
			});
			
			_changeState.transitionTo(_state2, _state1).trigger();
			assertThat(exited, equalTo(true));
		}
		
		[Test]
		public function testGuard():void
		{
			_changeState.transitionTo(_state2, _state1, function():Boolean
			{
				return false;
			}).trigger();
			assertThat(_machine.current, equalTo(_state1));
		}
		
		[Test]
		public function testTransitionTo():void
		{
			_changeState.transitionTo(_state2, _state1).trigger();
			assertThat(_machine.current, equalTo(_state2));
		}
		
		[Test]
		public function testTransitionToFromMultiple():void
		{
			_changeState.transitionTo(_state2, [_state1, _state3]).trigger();
			assertThat(_machine.current, equalTo(_state2));
		}
		
		[Test]
		public function testListen():void
		{
			var dispatcher:EventDispatcher = new EventDispatcher();
			_machine.listen(dispatcher, Event.ACTIVATE).transitionTo(_state2, _state1);
			dispatcher.dispatchEvent(new Event(Event.ACTIVATE));
			assertThat(_machine.current, equalTo(_state2));
		}
	}
}