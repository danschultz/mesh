package mesh.core.range
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	
	import mesh.core.reflection.clazz;

	/**
	 * A type that represents values between a lower and upper limit, such as a range 
	 * <em>from 5 up to 10</em>. <code>Range</code> has built in support for integers, single 
	 * character strings, and dates.
	 * 
	 * <p>
	 * Ranges supports iteration through the <code>for each..in</code> syntax.
	 * 
	 * <listing version="3.0">
	 * for each (var num:int in Range.from(5).to(10)) {
	 * 	trace(num);
	 * }
	 * 
	 * // traces
	 * // 5
	 * // 6
	 * // 7
	 * // 8
	 * // 9
	 * // 10
	 * </listing>
	 * </p>
	 * 
	 * <p>
	 * You may sub-class <code>Range</code> to support custom types of objects. You will need
	 * to override the following methods:
	 * 
	 * <ul>
	 * <li><code>decrement()</code></li>
	 * <li><code>increment()</code></li>
	 * <li><code>length</code></li>
	 * </ul>
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Range extends Proxy
	{
		/**
		 * Constructor.
		 * 
		 * @param from The starting value in the range.
		 * @param to The ending value in the range.
		 * @param exclusive If the ending value is not included.
		 * @throws ArgumentError If the start and end values are not the same type.
		 */
		public function Range(from:*, to:*, exclusive:Boolean = false)
		{
			var type:Class = clazz(to);
			if (!(from is type)) {
				throw new ArgumentError("Range values must be the same type.");
			}
			
			_from = from;
			_to = to;
			_isExclusive = exclusive;
			_isReversed = from > to;
		}
		
		/**
		 * Returns a builder for an integer, string, or date based range depending on the 
		 * <code>value</code> passed in.
		 * 
		 * <p>
		 * <strong>Example:</strong> Creating a new range.
		 * <listing version="3.0">
		 * trace( Range.from(1).to(5) ); // 1..5
		 * trace( from(1).to(5) ); // 1..5
		 * </listing>
		 * </p>
		 * 
		 * @param value The range's starting value.
		 * @return A range builder.
		 */
		public static function from(value:*):RangeBuilder
		{
			var clazz:Class;
			
			if (value is Number) {
				clazz = IntRange;
			} else if (value is String) {
				clazz = CharRange;
			} else if (value is Date) {
				clazz = DateRange;
			} else {
				throw new IllegalOperationError("Range.from() only supports Number, String, and Date.");
			}
			
			return new RangeBuilder(clazz, value);
		}
		
		/**
		 * Checks if the given value is between <code>from</code> and <code>to</code>, such that
		 * <code>min <= value <= max</code> or <code>min <= value < max</code> when <code>isExclusive</code>
		 * is <code>true</code>
		 * 
		 * @param value The value to check.
		 * @return <code>true</code> if the value is covered.
		 */
		public function contains(value:Object):Boolean
		{
			try {
				if (_isReversed) {
					return (!_isExclusive ? value >= min : value > min) && value <= max;
				}
				return value >= min && (!_isExclusive ? value <= max : value < max);
			} catch (e:Error) {
				
			}
			return false;
		}
		
		/**
		 * Runs an iteration through each element in the range, and passes in the element to
		 * the specified block.
		 * 
		 * @param block The block executed for each element.
		 */
		public function forEach(block:Function):void
		{
			step(1, block);
		}
		
		/**
		 * Iterates over each <em>n</em>th element in the range, and passing that element to
		 * the given block function.
		 * 
		 * @param size The iteration size.
		 * @param block The block executed for each <em>n</em>th element.
		 */
		public function step(size:int, block:Function):void
		{
			size = Math.max(1, size);
			
			var iterator:RangeIterator = newIterator(size);
			while (iterator.hasNext()) {
				block(iterator.next());
			}
		}
		
		/**
		 * Returns an array of all elements in the range.
		 * 
		 * @return An array.
		 */
		public function toArray():Array
		{
			var result:Array = [];
			forEach(function(element:Object):void
			{
				result.push(element);
			});
			return result;
		}
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return from + ".." + to;
		}
		
		/**
		 * Called during a reversed iteration of the range to return the next value.
		 * This method must be overridden by sub-classes.
		 * 
		 * <p>
		 * <strong>Example:</strong> Implementing an iteration for an integer.
		 * <listing version="3.0">
		 * override protected function decrease(value:*, size:int):*
		 * {
		 * 	return value-size;
		 * }
		 * </listing>
		 * </p>
		 * 
		 * @param value The current iteration value.
		 * @param size The step size of the iteration.
		 * @return The next value.
		 */
		protected function decrease(value:*, size:int):*
		{
			throw new IllegalOperationError(getQualifiedClassName(this) + ".decrease() is not implemented.");
		}
		
		/**
		 * Called during a ascending iteration of the range to return the next value.
		 * This method must be overridden by sub-classes.
		 * 
		 * <p>
		 * <strong>Example:</strong> Implementing an iteration for an integer.
		 * <listing version="3.0">
		 * override protected function increase(value:*, size:int):*
		 * {
		 * 	return value+size;
		 * }
		 * </listing>
		 * </p>
		 * 
		 * @param value The current iteration value.
		 * @param size The step size of the iteration.
		 * @return The next value.
		 */
		protected function increase(value:*, size:int):*
		{
			throw new IllegalOperationError(getQualifiedClassName(this) + ".increase() is not implemented.");
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iterator:RangeIterator;
		/**
		 * @private
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iterator = newIterator(1);
			}
			return _iterator.hasNext() ? index+1 : 0;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iterator.next();
		}
		
		private function newIterator(size:int):RangeIterator
		{
			return new RangeIterator(this, new RangeSequence(from, size, _isReversed ? decrease : increase));
		}
		
		private var _isExclusive:Boolean;
		/**
		 * <code>true</code> if the last value in the range is excluded.
		 */
		public function get isExclusive():Boolean
		{
			return _isExclusive;
		}
		
		private var _isReversed:Boolean;
		/**
		 * <code>true</code> if the this range is descending, i.e. <em>from 5 to 1</em> is reversed.
		 */
		public function get isReversed():Boolean
		{
			return _isReversed;
		}
		
		private var _from:*;
		/**
		 * The starting value in the range.
		 */
		public function get from():*
		{
			return _from;
		}
		
		private var _to:*;
		/**
		 * The ending value in the rnage.
		 */
		public function get to():*
		{
			return _to;
		}
		
		/**
		 * The minimum value in the range. This property returns the same value whether the range
		 * is reversed or not.
		 */
		public function get min():*
		{
			return to < from ? to : from;
		}
		
		/**
		 * The maximum value in the range. This property returns the same value whether the range
		 * is reversed or not.
		 */
		public function get max():*
		{
			return to > from ? to : from;
		}
		
		/**
		 * The number of elements in the range. Sub-classes must override and implement
		 * this property.
		 */
		public function get length():int
		{
			throw new IllegalOperationError(getQualifiedClassName(this) + ".length is not implemented.");
		}
	}
}

import mesh.core.range.Range;

class RangeIterator
{
	private var _range:Range;
	private var _sequence:RangeSequence;
	
	public function RangeIterator(range:Range, sequence:RangeSequence)
	{
		_range = range;
		_sequence = sequence;
	}
	
	public function hasNext():Boolean
	{
		return _range.contains(_sequence.value); 
	}
	
	public function next():Object
	{
		var value:Object = _sequence.value;
		_sequence = _sequence.next();
		return value;
	}
}

class RangeSequence
{
	private var _incrementorOrDecrementor:Function;
	private var _size:int;
	
	public function RangeSequence(value:*, size:int, incrementorOrDecrementor:Function)
	{
		_value = value;
		_size = size;
		_incrementorOrDecrementor = incrementorOrDecrementor;
	}
	
	public function next():RangeSequence
	{
		return new RangeSequence(_incrementorOrDecrementor(value, _size), _size, _incrementorOrDecrementor);
	}
	
	private var _value:*;
	public function get value():*
	{
		return _value;
	}
}